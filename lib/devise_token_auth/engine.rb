require 'devise_token_auth/rails/routes'

module DeviseTokenAuth
  class Engine < ::Rails::Engine
    isolate_namespace DeviseTokenAuth

    initializer "devise_token_auth.url_helpers" do
      Devise.helpers << DeviseTokenAuth::Controllers::Helpers
    end
  end

  mattr_accessor :change_headers_on_each_request,
                 :token_lifespan,
                 :batch_request_buffer_throttle,
                 :omniauth_prefix,
                 :require_confirm_success_url

  self.change_headers_on_each_request = true
  self.token_lifespan                 = 2.weeks
  self.batch_request_buffer_throttle  = 5.seconds
  self.omniauth_prefix                = '/omniauth'
  self.require_confirm_success_url    = true

  def self.setup(&block)
    yield self

    Rails.application.config.after_initialize do
      if defined?(::OmniAuth)
        ::OmniAuth::config.path_prefix = Devise.omniauth_path_prefix = self.omniauth_prefix
      end
    end
  end
end
