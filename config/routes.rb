Rails.application.routes.draw do
  if defined?(::OmniAuth)
    get "#{DeviseTokenAuth.omniauth_prefix}/:provider/callback", to: "devise_token_auth/omniauth_callbacks#redirect_callbacks"
    get "#{DeviseTokenAuth.omniauth_prefix}/failure", to: "devise_token_auth/omniauth_callbacks#omniauth_failure"
  end
end
