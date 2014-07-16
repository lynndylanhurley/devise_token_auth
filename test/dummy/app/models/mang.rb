class Mang < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
end
