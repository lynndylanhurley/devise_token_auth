# frozen_string_literal: true

class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
  include FavoriteColor

  devise :omniauthable
end
