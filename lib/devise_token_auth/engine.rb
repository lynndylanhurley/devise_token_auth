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
                 :excluded_modules

  self.change_headers_on_each_request = true
  self.token_lifespan                 = 2.weeks
  self.batch_request_buffer_throttle  = 5.seconds
  self.omniauth_prefix                = '/omniauth'
  self.excluded_modules               = []

  def self.setup(&block)
    yield self
  end

  def self.modules
    available_modules = [
      :database_authenticatable,
      :registerable,
      :recoverable,
      :rememberable,
      :trackable,
      :validatable,
      :confirmable,
      :omniauthable
    ]

    available_modules - excluded_modules
  end
end
