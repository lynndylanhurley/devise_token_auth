Rails.application.routes.draw do
  # when using multiple models, controllers will default to the first available
  # devise mapping. routes for subsequent devise mappings will need to defined
  # within a `devise_scope` block

  # define :users as the first devise mapping:
  mount_devise_token_auth_for 'User', at: '/auth'

  # define :mangs as the second devise mapping. routes using this class will
  # need to be defined within a devise_scope as shown below
  mount_devise_token_auth_for "Mang", at: '/mangs'

  # this route will authorize visitors using the User class
  get 'demo/members_only', to: 'demo_user#members_only'

  # routes within this block will authorize visitors using the Mang class
  get 'demo/members_only_mang', to: 'demo_mang#members_only'

  # routes within this block will authorize visitors using the Mang or User class
  get 'demo/members_only_group', to: 'demo_group#members_only'
end
