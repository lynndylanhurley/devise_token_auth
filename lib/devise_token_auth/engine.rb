require 'devise_token_auth/rails/routes'

module DeviseTokenAuth
  class Engine < ::Rails::Engine
    isolate_namespace DeviseTokenAuth

    initializer "devise_token_auth.helpers" do
      Devise.helpers << DeviseTokenAuth::Controllers::Helpers
    end
  end
end
