class <%= user_class %> < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
end
