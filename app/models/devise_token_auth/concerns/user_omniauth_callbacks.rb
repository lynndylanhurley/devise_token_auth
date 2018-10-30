# frozen_string_literal: true

module DeviseTokenAuth::Concerns::UserOmniauthCallbacks
  extend ActiveSupport::Concern

  included do
    validates :email, presence: true,if: :email_provider?
    validates :email, 'devise_token_auth/email' => true, allow_nil: true, allow_blank: true, if: :email_provider?
    validates_presence_of :uid, unless: :email_provider?

    # only validate unique emails among email registration users
    validates :email, uniqueness: { scope: :provider }, on: :create, if: :email_provider?

    # keep uid in sync with email
    before_save :sync_uid
    before_create :sync_uid
  end

  protected

  def email_provider?
    provider == 'email'
  end

  def sync_uid
    self.uid = email if provider == 'email'
  end
end
