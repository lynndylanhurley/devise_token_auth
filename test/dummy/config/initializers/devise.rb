Devise.setup do |config|
  config.authentication_keys = [:email, :username]
  config.case_insensitive_keys = [:email, :username]
end
