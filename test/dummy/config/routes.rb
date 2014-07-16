Rails.application.routes.draw do
  # when using multiple models, controllers will default to the first available
  # devise mapping. routes for subsequent devise mappings will need to defined
  # within a `devise_scope` block

  # define :users as the first devise mapping:
  mount_devise_token_auth_for 'User', at: '/auth'

  # define :mangs as the second devise mapping. routes using this class will
  # need to be defined within a devise_scope as shown below
  mount_devise_token_auth_for "Mang", at: '/bong'

  # this route will authorize visitors using the User class
  get 'demo/members_only', to: 'demo#members_only'

  # routes within this block will authorize visitors using the Mang class
  devise_scope :mang do
    get 'demo/members_only_mang', to: 'demo#members_only'
  end
end
