class Account < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
  belongs_to :owner, polymorphic: true
  has_one :profile
end
