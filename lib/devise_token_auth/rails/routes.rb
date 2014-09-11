module ActionDispatch::Routing
  class Mapper
    def mount_devise_token_auth_for(resource, opts)
      scope opts[:at] do
        devise_for resource.pluralize.underscore.to_sym,
          :class_name  => resource,
          :module      => :devise,
          :path        => "",
          :controllers => {:sessions      => "devise_token_auth/sessions",
                           :registrations => "devise_token_auth/registrations",
                           :passwords     => "devise_token_auth/passwords",
                           :confirmations => "devise_token_auth/confirmations"}

        devise_scope resource.underscore.to_sym do
          get "validate_token",      to: "devise_token_auth/auth#validate_token"
          if defined?(::OmniAuth)
            get "failure",             to: "devise_token_auth/auth#omniauth_failure"
            get ":provider/callback",  to: "devise_token_auth/auth#omniauth_success"
            post ":provider/callback", to: "devise_token_auth/auth#omniauth_success"

            # preserve the resource class thru oauth authentication by setting name of
            # resource as "resource_class" param
            match ":provider", to: redirect{|params, request|
              # get the current querystring
              qs = CGI::parse(request.env["QUERY_STRING"])

              # append name of current resource
              qs["resource_class"] = [resource]

              # re-construct the path for omniauth
              "#{::OmniAuth::config.path_prefix}/#{params[:provider]}?#{{}.tap {|hash| qs.each{|k, v| hash[k] = v.first}}.to_param}"
            }, via: [:get]
          end
        end
      end
    end
  end
end
