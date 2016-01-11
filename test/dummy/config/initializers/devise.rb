Devise.setup do |config|
  config.authentication_keys = [:email, :nickname]

  require 'devise/orm/mongoid'
end
