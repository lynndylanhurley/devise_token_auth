class EvilUser < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
end
