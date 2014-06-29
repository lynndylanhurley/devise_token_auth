DeviseTokenAuth::Engine.routes.draw do
  devise_for :users,
    :class_name => "User",
    :module => :devise,
    :path => "",
    :controllers => {:sessions => "devise_token_auth/sessions",
                     :registrations => "devise_token_auth/registrations",
                     :passwords => "devise_token_auth/passwords",
                     :confirmations => "devise_token_auth/confirmations"}

  post "validate_token", to: "devise_token_auth/auth#validate_token"

  get "failure", to: "devise_token_auth/auth#omniauth_failure"
  get ":provider/callback", to: "devise_token_auth/auth#omniauth_success"
end
