module DeviseTokenAuth::Concerns::UserOmniauthCallbacks
  extend ActiveSupport::Concern

  included do
    validates :email, presence: true, email: true, if: Proc.new { |u| u.provider == 'email' }
    validates_presence_of :uid, if: Proc.new { |u| u.provider != 'email' }

    # only validate unique emails among email registration users
    validate :unique_email_user, on: :create

    # keep uid in sync with email
    before_save :sync_uid
    before_create :sync_uid
  end

  protected

  # only validate unique email among users that registered by email
  def unique_email_user
    if provider == 'email' && self.class.where(provider: 'email', email: email).count > 0
      errors.add(:email, :taken)
    end
  end

  def sync_uid
    self.uid = email if provider == 'email'
  end
end
