Rails.application.routes.draw do
  if defined?(::OmniAuth)
    get "#{::OmniAuth::config.path_prefix}/:provider/callback", to: "devise_token_auth/omniauth_callbacks#redirect_callbacks"
  end
end
