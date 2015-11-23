class FacebookUser < ActiveRecord::Base
  has_one :user, class_name: MultiAuthUser
end
