Rails.application.routes.draw do
  mount DeviseTokenAuth::Engine => "/auth"

  get 'test/members_only', to: 'test#members_only'
end
