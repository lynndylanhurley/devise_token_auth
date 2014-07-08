class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable,
        :confirmable

  serialize :tokens, JSON

  # only validate unique emails among email registration users
  validates_presence_of :email, if: Proc.new { |u| u.provider == 'email' }
  validates_presence_of :confirm_success_url, if: Proc.new {|u| u.provider == 'email'}

  validate :unique_email_user, on: :create

  def valid_token?(client_id, token)
    return false unless self.tokens[client_id]['expiry'] > 2.weeks.ago
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
      errors.add(:email, "Your email address is already in use")
    end
  end

  def email_required?
    provider == 'email'
  end
end
