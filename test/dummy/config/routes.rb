Rails.application.routes.draw do
  # when using multiple models, controllers will default to the first available
  # devise mapping. routes for subsequent devise mappings will need to defined
  # within a `devise_scope` block

  # define :users as the first devise mapping:
  mount_devise_token_auth_for 'User', at: 'auth'

  # define :mangs as the second devise mapping. routes using this class will
  # need to be defined within a devise_scope as shown below
  mount_devise_token_auth_for "Mang", at: 'mangs'

  mount_devise_token_auth_for 'EvilUser', at: 'evil_user_auth', controllers: {
    confirmations:      'overrides/confirmations',
    passwords:          'overrides/passwords',
    omniauth_callbacks: 'overrides/omniauth_callbacks',
    registrations:      'overrides/registrations',
    sessions:           'overrides/sessions',
    token_validations:  'overrides/token_validations'
  }

  mount_devise_token_auth_for 'NiceUser', at: 'nice_user_auth', controllers: {
    registrations: 'custom/registrations',
    confirmations: 'custom/confirmations',
    passwords: 'custom/passwords',
    sessions: 'custom/sessions',
    token_validations: 'custom/token_validations',
    omniauth_callbacks: 'custom/omniauth_callbacks'
  }

  mount_devise_token_auth_for 'OnlyEmailUser', at: 'only_email_auth', skip: [:omniauth_callbacks]

  mount_devise_token_auth_for 'UnregisterableUser', at: 'unregisterable_user_auth', skip: [:registrations]

  mount_devise_token_auth_for 'UnconfirmableUser', at: 'unconfirmable_user_auth'

  mount_devise_token_auth_for 'LockableUser', at: 'lockable_user_auth'

  # test namespacing
  namespace :api do
    scope :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
    end
  end

  # test namespacing with not created devise mapping
  namespace :api_v2, defaults: { format: :json } do
    mount_devise_token_auth_for "ScopedUser",
      at:          "auth",
      controllers: {
        omniauth_callbacks: "api_v2/omniauth_callbacks",
        sessions:           "api_v2/sessions",
        registrations:      "api_v2/registrations",
        confirmations:      "api_v2/confirmations",
        passwords:          "api_v2/passwords"
      }
  end

  # this route will authorize visitors using the User class
  get 'demo/members_only', to: 'demo_user#members_only'
  get 'demo/members_only_remove_token', to: 'demo_user#members_only_remove_token'


  # routes within this block will authorize visitors using the Mang class
  get 'demo/members_only_mang', to: 'demo_mang#members_only'

  # routes within this block will authorize visitors using the Mang or User class
  get 'demo/members_only_group', to: 'demo_group#members_only'

  # we need a route for omniauth_callback_controller to redirect to in sameWindow case
  get 'auth_origin', to: 'auth_origin#redirected'
end
