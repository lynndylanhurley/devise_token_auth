# frozen_string_literal: true

Devise.setup do |config|
  config.authentication_keys = [:email, :nickname]
end
