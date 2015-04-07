module DeviseTokenAuth::Concerns::User
  extend ActiveSupport::Concern

  included do
    # Hack to check if devise is already enabled
    unless self.method_defined?(:devise_modules)
      devise :database_authenticatable, :registerable,
          :recoverable, :trackable, :validatable, :confirmable
    else
      self.devise_modules.delete(:omniauthable)
    end

    serialize :tokens, JSON

    validates :email, presence: true, email: true, if: Proc.new { |u| u.provider == 'email' }
    validates_presence_of :uid, if: Proc.new { |u| u.provider != 'email' }

    # only validate unique emails among email registration users
    validate :unique_email_user, on: :create

    # can't set default on text fields in mysql, simulate here instead.
    after_save :set_empty_token_hash
    after_initialize :set_empty_token_hash

    # keep uid in sync with email
    before_save :sync_uid
    before_create :sync_uid

    # get rid of dead tokens
    before_save :destroy_expired_tokens

    # don't use default devise email validation
    def email_required?
      false
    end

    def email_changed?
      false
    end

    # override devise method to include additional info as opts hash
    def send_confirmation_instructions(opts=nil)
      unless @raw_confirmation_token
        generate_confirmation_token!
      end

      opts ||= {}

      # fall back to "default" config name
      opts[:client_config] ||= "default"

      if pending_reconfirmation?
        opts[:to] = unconfirmed_email
      end

      send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
    end

    # override devise method to include additional info as opts hash
    def send_reset_password_instructions(opts=nil)
      token = set_reset_password_token

      opts ||= {}

      # fall back to "default" config name
      opts[:client_config] ||= "default"

      if pending_reconfirmation?
        opts[:to] = unconfirmed_email
      else
        opts[:to] = email
      end

      send_devise_notification(:reset_password_instructions, token, opts)

      token
    end
  end


  def valid_token?(token, client_id='default')
    client_id ||= 'default'

    return false unless self.tokens[client_id]

    return true if token_is_current?(token, client_id)
    return true if token_can_be_reused?(token, client_id)

    # return false if none of the above conditions are met
    return false
  end


  # this must be done from the controller so that additional params
  # can be passed on from the client
  def send_confirmation_notification?
    false
  end


  def token_is_current?(token, client_id)
    # ghetto HashWithIndifferentAccess
    expiry     = self.tokens[client_id]['expiry'] || self.tokens[client_id][:expiry]
    token_hash = self.tokens[client_id]['token'] || self.tokens[client_id][:token]

    return true if (
      # ensure that expiry and token are set
      expiry and token and

      # ensure that the token has not yet expired
      DateTime.strptime(expiry.to_s, '%s') > Time.now and

      # ensure that the token is valid
      BCrypt::Password.new(token_hash) == token
    )
  end


  # allow batch requests to use the previous token
  def token_can_be_reused?(token, client_id)
    # ghetto HashWithIndifferentAccess
    updated_at = self.tokens[client_id]['updated_at'] || self.tokens[client_id][:updated_at]
    last_token = self.tokens[client_id]['last_token'] || self.tokens[client_id][:last_token]


    return true if (
      # ensure that the last token and its creation time exist
      updated_at and last_token and

      # ensure that previous token falls within the batch buffer throttle time of the last request
      Time.parse(updated_at) > Time.now - DeviseTokenAuth.batch_request_buffer_throttle and

      # ensure that the token is valid
      BCrypt::Password.new(last_token) == token
    )
  end


  # update user's auth token (should happen on each request)
  def create_new_auth_token(client_id=nil)
    client_id  ||= SecureRandom.urlsafe_base64(nil, false)
    last_token ||= nil
    token        = SecureRandom.urlsafe_base64(nil, false)
    token_hash   = BCrypt::Password.create(token)
    expiry       = (Time.now + DeviseTokenAuth.token_lifespan).to_i

    if self.tokens[client_id] and self.tokens[client_id]['token']
      last_token = self.tokens[client_id]['token']
    end

    self.tokens[client_id] = {
      token:      token_hash,
      expiry:     expiry,
      last_token: last_token,
      updated_at: Time.now
    }

    self.save!

    return build_auth_header(token, client_id)
  end


  def build_auth_header(token, client_id='default')
    client_id ||= 'default'

    # client may use expiry to prevent validation request if expired
    # must be cast as string or headers will break
    expiry = self.tokens[client_id]['expiry'] || self.tokens[client_id][:expiry]

    return {
      "access-token" => token,
      "token-type"   => "Bearer",
      "client"       => client_id,
      "expiry"       => expiry.to_s,
      "uid"          => self.uid
    }
  end


  def build_auth_url(base_url, args)
    args[:uid]    = self.uid
    args[:expiry] = self.tokens[args[:client_id]]['expiry']

    generate_url(base_url, args)
  end


  def extend_batch_buffer(token, client_id)
    self.tokens[client_id]['updated_at'] = Time.now
    self.save!

    return build_auth_header(token, client_id)
  end

  def confirmed?
    self.devise_modules.exclude?(:confirmable) || super
  end

  def token_validation_response
    self.as_json(except: [
      :tokens, :created_at, :updated_at
    ])
  end


  protected


  # NOTE: ensure that fragment comes AFTER querystring for proper $location
  # parsing using AngularJS.
  def generate_url(url, params = {})
    uri = URI(url)

    res = "#{uri.scheme}://#{uri.host}"
    res += ":#{uri.port}" if (uri.port and uri.port != 80 and uri.port != 443)
    res += "#{uri.path}" if uri.path
    res += '#'
    res += "#{uri.fragment}" if uri.fragment
    res += "?#{params.to_query}"

    return res
  end

  # only validate unique email among users that registered by email
  def unique_email_user
    if provider == 'email' and self.class.where(provider: 'email', email: email).count > 0
      errors.add(:email, :already_in_use, default: "This email address is already in use")
    end
  end

  def set_empty_token_hash
    self.tokens ||= {} if has_attribute?(:tokens)
  end

  def sync_uid
    self.uid = email if provider == 'email'
  end

  def destroy_expired_tokens
    self.tokens.delete_if{|cid,v|
      expiry = v[:expiry] || v["expiry"]
      DateTime.strptime(expiry.to_s, '%s') < Time.now
    }
  end

end
