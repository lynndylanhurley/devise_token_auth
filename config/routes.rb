Rails.application.routes.draw do
  get "#{::OmniAuth::config.path_prefix}/:provider/callback", to: 'devise_token_auth/auth#omniauth_success'
end
