DeviseTokenAuth::Engine.routes.draw do
  devise_for :users,
    :class_name  => "User",
    :module      => :devise,
    :path        => "",
    :controllers => {:sessions      => "devise_token_auth/sessions",
                     :registrations => "devise_token_auth/registrations",
                     :passwords     => "devise_token_auth/passwords",
                     :confirmations => "devise_token_auth/confirmations"}

  get "validate_token",    to: "auth#validate_token"
  get "failure",            to: "auth#omniauth_failure"
  get ":provider/callback", to: "auth#omniauth_success"
end
