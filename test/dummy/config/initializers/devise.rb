# frozen_string_literal: true

Devise.setup do |config|
  config.authentication_keys = [:email, :nickname]

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class
  # with default "from" parameter.
  config.mailer_sender = 'no-reply@example.com'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require "devise/orm/#{DEVISE_TOKEN_AUTH_ORM}"
end
