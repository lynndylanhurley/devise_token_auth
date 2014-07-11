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
    # ensure token was created within last two weeks
    return false unless self.tokens[client_id]['expiry'] > 2.weeks.ago

    # ensure token is valid
    return false unless BCrypt::Password.new(self.tokens[client_id]['token']) == token

    return true
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

  def create_new_auth_token(client_id=nil)
    # update user's auth token (should happen on each request)
    client_id  ||= SecureRandom.urlsafe_base64(nil, false)
    token        = SecureRandom.urlsafe_base64(nil, false)
    token_hash   = BCrypt::Password.create(token)

    self.tokens[client_id] = {
      token:  token_hash,
      expiry: Time.now + 2.weeks
    }
    self.save

    return "token=#{token} client=#{client_id} uid=#{self.uid}"
  end

  def get_auth_header(client_id)
    token_info = self.tokens[client_id]
    return "token=#{token_info.token} client=#{client_id} uid=#{self.uid}"
  end
end
