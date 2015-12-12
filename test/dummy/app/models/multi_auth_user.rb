class MultiAuthUser < ActiveRecord::Base
  devise :database_authenticatable, :registerable

  include DeviseTokenAuth::Concerns::User

  resource_finder_for :twitter,  ->(twitter_id)  { find_by(twitter_id: twitter_id) }
  resource_finder_for :facebook, ->(facebook_id) { FacebookUser.find_by(facebook_id: facebook_id).user }

  belongs_to :facebook_user

end
