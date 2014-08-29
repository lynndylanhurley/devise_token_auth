class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User

  validates :operating_thetan, numericality: true, allow_nil: true
end
