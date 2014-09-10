module DeviseTokenAuth::Concerns::User
  extend ActiveSupport::Concern

  included do
    BLACKLIST_FOR_SERIALIZATION = [:tokens]

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable

    serialize :tokens, JSON

    validates_presence_of :email, if: Proc.new { |u| u.provider == 'email' }
    validates_presence_of :confirm_success_url, if: Proc.new {|u| u.provider == 'email'}

    # only validate unique emails among email registration users
    validate :unique_email_user, on: :create

    # can't set default on text fields in mysql, simulate here instead.
    after_save :set_empty_token_hash
    after_initialize :set_empty_token_hash

    # don't use default devise email validation
    def email_required?
      false
    end

    def email_changed?
      false
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


  def token_is_current?(token, client_id)
    return true if (
      # ensure that expiry and token are set
      self.tokens[client_id]['expiry'] and
      self.tokens[client_id]['token'] and

      # ensure that the token was created within the last two weeks
      DateTime.strptime(self.tokens[client_id]['expiry'].to_s, '%s') > DeviseTokenAuth.token_lifespan.ago and

      # ensure that the token is valid
      BCrypt::Password.new(self.tokens[client_id]['token']) == token
    )
  end


  # allow batch requests to use the previous token
  def token_can_be_reused?(token, client_id)
    return true if (
      # ensure that the last token and its creation time exist
      self.tokens[client_id]['updated_at'] and
      self.tokens[client_id]['last_token'] and

      # ensure that previous token falls within the batch buffer throttle time of the last request
      Time.parse(self.tokens[client_id]['updated_at']) > Time.now - DeviseTokenAuth.batch_request_buffer_throttle and

      # ensure that the token is valid
      BCrypt::Password.new(self.tokens[client_id]['last_token']) == token
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
    expiry = self.tokens[client_id]['expiry'].to_s

    return {
      "access-token" => token,
      "token-type"   => "Bearer",
      "client"       => client_id,
      "expiry"       => expiry,
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


  protected


  # ensure that fragment comes AFTER querystring for proper $location
  # parsing using AngularJS.
  def generate_url(url, params = {})
    uri = URI(url)

    res = "#{uri.scheme}://#{uri.host}"
    res += ":#{uri.port}" if (uri.port and uri.port != 80 and uri.port != 443)
    res += "#{uri.path}" if uri.path
    res += "##{uri.fragment}" if uri.fragment
    res += "?#{params.to_query}"

    return res
  end


  # only validate unique email among users that registered by email
  def unique_email_user
    if provider == 'email' and self.class.where(provider: 'email', email: email).count > 0
      errors.add(:email, "This email address is already in use")
    end
  end

  def set_empty_token_hash
    self.tokens ||= {} if has_attribute?(:tokens)
  end
end
