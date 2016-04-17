module DeviseTokenAuth::Concerns::UserOmniauthCallbacks
  extend ActiveSupport::Concern

  included do
    validates :email, presence: true, email: true, if: Proc.new { |u| u.provider == 'email' }
    validates_presence_of :uid, if: Proc.new { |u| u.provider != 'email' }

    # only validate unique emails among email registration users
    validate :unique_email_user, if: Proc.new { |u| u.provider == 'email' && u.email_change }

    # keep uid in sync with email
    before_save :sync_uid, if: Proc.new { |u| u.provider == 'email' }
  end

  protected

  # only validate unique email among users that registered by email
  def unique_email_user
    if self.class.where(provider: 'email', email: email).exists?
      errors.add(:email, I18n.t("errors.messages.already_in_use"))
    end
  end

  def sync_uid
    self.uid = email
  end
end
