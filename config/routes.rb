DeviseTokenAuth::Engine.routes.draw do
  begin
    devise_for :users,
      :class_name  => DeviseTokenAuth.user_class.to_s,
      :module      => :devise,
      :path        => "",
      :controllers => {:sessions      => "devise_token_auth/sessions",
                      :registrations => "devise_token_auth/registrations",
                      :passwords     => "devise_token_auth/passwords",
                      :confirmations => "devise_token_auth/confirmations"}

    get "validate_token",     to: "auth#validate_token"
    get "failure",            to: "auth#omniauth_failure"
    get ":provider/callback",  to: "auth#omniauth_success"
    post ":provider/callback", to: "auth#omniauth_success"
  rescue NameError
  end
end
