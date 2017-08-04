require "devise"
require "devise_token_auth/engine"
require "devise_token_auth/controllers/helpers"
require "devise_token_auth/url"

module DeviseTokenAuth
  mattr_accessor :change_headers_on_each_request
  @@change_headers_on_each_request = true

  mattr_accessor :max_number_of_devices
  @@max_number_of_devices = 10

  mattr_accessor :token_lifespan
  @@token_lifespan = 2.weeks

  mattr_accessor :batch_request_buffer_throttle
  @@batch_request_buffer_throttle = 5.seconds

  mattr_accessor :omniauth_prefix
  @@omniauth_prefix = '/omniauth'

  mattr_accessor :default_confirm_success_url
  @@default_confirm_success_url = nil

  mattr_accessor :default_password_reset_url
  @@default_password_reset_url = nil

  mattr_accessor :redirect_whitelist
  @@redirect_whitelist = nil

  mattr_accessor :check_current_password_before_update
  @@check_current_password_before_update = false

  mattr_accessor :enable_standard_devise_support
  @@enable_standard_devise_support = false

  mattr_accessor :remove_tokens_after_password_reset
  @@remove_tokens_after_password_reset = false

  mattr_accessor :default_callbacks
  @@default_callbacks = true

  # TODO: Remove
  mattr_accessor :headers_names
  @@headers_names  = {
    :'access-token' => 'access-token',
    :'client' => 'client',
    :'expiry' => 'expiry',
    :'uid' => 'uid',
    :'token-type' => 'token-type'
  }

  mattr_accessor :access_token_name
  @@access_token_name = 'access-token'

  mattr_accessor :client_name
  @@client_name = 'client'

  mattr_accessor :expiry_name
  @@expiry_name = 'expiry'

  mattr_accessor :uid_name
  @@uid_name = 'uid'

  mattr_accessor :token_type_name
  @@token_type_name = 'token-type'

  def self.setup(&block)
    yield self

    Rails.application.config.after_initialize do
      if defined?(::OmniAuth)
        ::OmniAuth::config.path_prefix = Devise.omniauth_path_prefix = self.omniauth_prefix


        # Omniauth currently does not pass along omniauth.params upon failure redirect
        # see also: https://github.com/intridea/omniauth/issues/626
        OmniAuth::FailureEndpoint.class_eval do
          def redirect_to_failure
            message_key = env['omniauth.error.type']
            origin_query_param = env['omniauth.origin'] ? "&origin=#{CGI.escape(env['omniauth.origin'])}" : ""
            strategy_name_query_param = env['omniauth.error.strategy'] ? "&strategy=#{env['omniauth.error.strategy'].name}" : ""
            extra_params = env['omniauth.params'] ? "&#{env['omniauth.params'].to_query}" : ""
            new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{message_key}#{origin_query_param}#{strategy_name_query_param}#{extra_params}"
            Rack::Response.new(["302 Moved"], 302, 'Location' => new_path).finish
          end
        end


        # Omniauth currently removes omniauth.params during mocked requests
        # see also: https://github.com/intridea/omniauth/pull/812
        OmniAuth::Strategy.class_eval do
          def mock_callback_call
            setup_phase
            @env['omniauth.origin'] = session.delete('omniauth.origin')
            @env['omniauth.origin'] = nil if env['omniauth.origin'] == ''
            @env['omniauth.params'] = session.delete('omniauth.params') || {}
            mocked_auth = OmniAuth.mock_auth_for(name.to_s)
            if mocked_auth.is_a?(Symbol)
              fail!(mocked_auth)
            else
              @env['omniauth.auth'] = mocked_auth
              OmniAuth.config.before_callback_phase.call(@env) if OmniAuth.config.before_callback_phase
              call_app!
            end
          end
        end
      end
    end
  end
end
