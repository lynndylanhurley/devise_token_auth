# frozen_string_literal: true

class TenantUser < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable
  include DeviseTokenAuth::Concerns::User

  # Override default email validation and handle the tenant field
  validates :email, uniqueness: { scope: [:tenant, :provider] }, on: :create

  def validate_email_uniqueness?
    false
  end
end
