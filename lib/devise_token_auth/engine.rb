require 'devise_token_auth/rails/routes'

module DeviseTokenAuth
  class Engine < ::Rails::Engine
    isolate_namespace DeviseTokenAuth

    initializer "devise_token_auth.url_helpers" do
      Devise.helpers << DeviseTokenAuth::Controllers::Helpers
    end

    initializer "devise_token_auth.omniauth_strategy" do
      if defined?(::OmniAuth)
        Devise.with_options model: true do |d|
          d.add_module(:dta_omniauthable, controller: :omniauth_callbacks, route: :omniauth_callbacks)
        end
      end
    end
  end

  mattr_accessor :change_headers_on_each_request,
                 :token_lifespan,
                 :batch_request_buffer_throttle,
                 :omniauth_prefix

  self.change_headers_on_each_request = true
  self.token_lifespan                 = 2.weeks
  self.batch_request_buffer_throttle  = 5.seconds
  self.omniauth_prefix                = '/omniauth'

  def self.setup(&block)
    yield self
  end
end
