Rails.application.routes.draw do
  mount DeviseTokenAuth::Engine => "/auth"
end
