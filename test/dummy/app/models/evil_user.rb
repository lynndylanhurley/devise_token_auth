# frozen_string_literal: true

class EvilUser < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
end
