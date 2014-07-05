Rails.application.routes.draw do
  mount DeviseTokenAuth::Engine => "/auth"

  get 'demo/members_only', to: 'demo#members_only'
end
