class User < ActiveRecord::Base
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

  def valid_token?(client_id, token)
    return true if (
      # ensure that expiry and token are set
      self.tokens[client_id]['expiry'] and
      self.tokens[client_id]['token'] and

      # ensure that the token was created within the last two weeks
      self.tokens[client_id]['expiry'] > DeviseTokenAuth.token_lifespan.ago.to_f * 1000 and

      # ensure that the token is valid
      BCrypt::Password.new(self.tokens[client_id]['token']) == token
    )

    return true if (
      # ensure that the last token and its creation time exist
      self.tokens[client_id]['updated_at'] and
      self.tokens[client_id]['last_token'] and

      # ensure that previous token falls within the batch buffer throttle time of the last request
      Time.parse(self.tokens[client_id]['updated_at']) > Time.now - DeviseTokenAuth.batch_request_buffer_throttle and

      # ensure that the token is valid
      BCrypt::Password.new(self.tokens[client_id]['last_token']) == token
    )

    # return false if none of the above conditions are met
    return false
  end


  def serializable_hash(options={})
    options ||= {}
    options[:except] ||= [:tokens]
    super(options)
  end


  # don't use default devise email validation
  def email_changed?
    false
  end


  def unique_email_user
    if provider == 'email' and User.where(provider: 'email', email: email).count > 0
      errors.add(:email, "This email address is already in use")
    end
  end


  def email_required?
    provider == 'email'
  end

  # update user's auth token (should happen on each request)
  def create_new_auth_token(client_id=nil)
    client_id  ||= SecureRandom.urlsafe_base64(nil, false)
    last_token ||= nil
    token        = SecureRandom.urlsafe_base64(nil, false)
    token_hash   = BCrypt::Password.create(token)
    expiry       = (Time.now.to_f + DeviseTokenAuth.token_lifespan).to_i * 1000

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

    return build_auth_header(client_id, token)
  end


  def extend_batch_buffer(client_id, token)
    self.tokens[client_id]['updated_at'] = Time.now
    self.save!

    return build_auth_header(client_id, token)
  end


  def build_auth_header(client_id, token)
    # client may use expiry to save validation request if expired
    expiry = self.tokens[client_id]['expiry']

    return "token=#{token} client=#{client_id} expiry=#{expiry} uid=#{self.uid}"
  end
end
