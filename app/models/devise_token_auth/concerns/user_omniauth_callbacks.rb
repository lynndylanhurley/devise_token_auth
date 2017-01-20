module DeviseTokenAuth::Concerns::UserOmniauthCallbacks
  extend ActiveSupport::Concern

  included do
    # NOTE: validating the email happens in the validatable submodule
    # FIX: validating the email twice when different validations needed for validatable
    # validates :email, presence: true, email: true, if: Proc.new { |u| u.provider == 'email' }

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
    if provider == 'email' and self.class.where(provider: 'email', email: email).count > 0
      errors.add(:email, :taken)
    end
  end

  def sync_uid
    self.uid = email if provider == 'email'
  end
end
