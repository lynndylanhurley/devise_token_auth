Rails.application.routes.draw do
  if defined?(::OmniAuth)
    match "#{::OmniAuth::config.path_prefix}/:provider/callback", to: redirect {|params, request|
      devise_mapping = request.env['omniauth.params']['resource_class'].underscore.to_sym
      mount_point = Devise.mappings[devise_mapping].as_json["path_prefix"]

      qs = {
        auth_hash:   request.env['omniauth.auth'],
        auth_params: request.env['omniauth.params']
      }.to_query

      "#{mount_point}/#{params[:provider]}/callback?#{qs}"
    }, via: :all
  end

end
