class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
end
