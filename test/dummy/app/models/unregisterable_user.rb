# frozen_string_literal: true

class UnregisterableUser < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable,
         :recoverable, :trackable, :validatable,
         :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User
end
