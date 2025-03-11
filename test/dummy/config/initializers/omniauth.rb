# frozen_string_literal: true

# OmniAuth.config.path_prefix = '/auth'
# OmniAuth.config.request_validation_phase = nil  # This might be needed for Rails 7.1

Rails.application.config.middleware.use OmniAuth::Builder do |b|
  provider :github,        ENV['GITHUB_KEY'],   ENV['GITHUB_SECRET'],   scope: 'email,profile'
  provider :facebook,      ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :google_oauth2, ENV['GOOGLE_KEY'],   ENV['GOOGLE_SECRET']
  provider :apple,         ENV['APPLE_CLIENT_ID'], '', { scope: 'email name', team_id: ENV['APPLE_TEAM_ID'], key_id: ENV['APPLE_KEY'], pem: ENV['APPLE_PEM'] }
  provider :developer,
           fields: [:first_name, :last_name],
           uid_field: :last_name
end

# Allow POST requests to OmniAuth
# OmniAuth.config.allowed_request_methods = [:post, :get]
