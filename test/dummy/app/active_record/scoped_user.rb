# frozen_string_literal: true

class ScopedUser < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User
end
