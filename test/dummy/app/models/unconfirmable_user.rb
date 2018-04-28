# frozen_string_literal: true

class UnconfirmableUser < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :trackable, :validatable,
         :omniauthable
  include DeviseTokenAuth::Concerns::User
end
