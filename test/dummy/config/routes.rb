Rails.application.routes.draw do
  mount_devise_token_auth_for "User", at: :auth
  mount_devise_token_auth_for "Mang", at: :bong

  get 'demo/members_only', to: 'demo#members_only'

  as :mang do
    get 'demo/members_only_mang', to: 'demo#members_only'
  end
end
