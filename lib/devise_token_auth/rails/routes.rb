module ActionDispatch::Routing
  class Mapper
    def mount_devise_token_auth_for(resource, opts)
      # ensure objects exist to simplify attr checks
      opts[:controllers] ||= {}
      opts[:skip]        ||= []

      # check for ctrl overrides, fall back to defaults
      sessions_ctrl          = opts[:controllers][:sessions] || "devise_token_auth/sessions"
      registrations_ctrl     = opts[:controllers][:registrations] || "devise_token_auth/registrations"
      passwords_ctrl         = opts[:controllers][:passwords] || "devise_token_auth/passwords"
      confirmations_ctrl     = opts[:controllers][:confirmations] || "devise_token_auth/confirmations"
      token_validations_ctrl = opts[:controllers][:token_validations] || "devise_token_auth/token_validations"
      omniauth_ctrl          = opts[:controllers][:omniauth_callbacks] || "devise_token_auth/omniauth_callbacks"

      # define devise controller mappings
      controllers = {:sessions           => sessions_ctrl,
                     :registrations      => registrations_ctrl,
                     :passwords          => passwords_ctrl,
                     :confirmations      => confirmations_ctrl,
                     :omniauth_callbacks => omniauth_ctrl}

      # remove any unwanted devise modules
      opts[:skip].each{|item| controllers.delete(item)}

      scope opts[:at] do
        devise_for resource.pluralize.underscore.to_sym,
          :class_name  => resource,
          :module      => :devise,
          :path        => "",
          :controllers => controllers

        devise_scope resource.underscore.to_sym do
          # path to verify token validity
          get "validate_token", to: "#{token_validations_ctrl}#validate_token"

          # omniauth routes. only define if omniauth is installed and not skipped.
          if defined?(::OmniAuth) and not opts[:skip].include?(:omniauth_callbacks)
            get "failure",             to: "#{omniauth_ctrl}#omniauth_failure"
            get ":provider/callback",  to: "#{omniauth_ctrl}#omniauth_success"

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

    # ignore error about omniauth/multiple model support
    def set_omniauth_path_prefix!(path_prefix)
      ::OmniAuth.config.path_prefix = path_prefix
    end

  end
end
