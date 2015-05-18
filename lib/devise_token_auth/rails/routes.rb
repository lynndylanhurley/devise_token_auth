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
                     :confirmations      => confirmations_ctrl}

      # remove any unwanted devise modules
      opts[:skip].each{|item| controllers.delete(item)}

      devise_for resource.pluralize.underscore.to_sym,
        :class_name  => resource,
        :module      => :devise,
        :path        => "#{opts[:at]}",
        :controllers => controllers,
        :skip        => opts[:skip] + [:omniauth_callbacks]

      unnest_namespace do
        # get full url path as if it were namespaced
        full_path = "#{@scope[:path]}/#{opts[:at]}"

        # clear scope so controller routes aren't namespaced
        @scope = ActionDispatch::Routing::Mapper::Scope.new(
          path:         "",
          shallow_path: "",
          constraints:  {},
          defaults:     {},
          options:      {},
          parent:       nil
        )

        devise_scope resource.underscore.to_sym do
          # path to verify token validity
          get "#{full_path}/validate_token", controller: "#{token_validations_ctrl}", action: "validate_token"

          # omniauth routes. only define if omniauth is installed and not skipped.
          if defined?(::OmniAuth) and not opts[:skip].include?(:omniauth_callbacks)
            match "#{full_path}/failure",             controller: omniauth_ctrl, action: "omniauth_failure", via: [:get]
            match "#{full_path}/:provider/callback",  controller: omniauth_ctrl, action: "omniauth_success", via: [:get]

            # preserve the resource class thru oauth authentication by setting name of
            # resource as "resource_class" param
            match "#{full_path}/:provider", to: redirect{|params, request|
              # get the current querystring
              qs = CGI::parse(request.env["QUERY_STRING"])

              # append name of current resource
              qs["resource_class"] = [resource]

              set_omniauth_path_prefix!(DeviseTokenAuth.omniauth_prefix)

              # re-construct the path for omniauth
              "#{::OmniAuth.config.path_prefix}/#{params[:provider]}?#{{}.tap {|hash| qs.each{|k, v| hash[k] = v.first}}.to_param}"
            }, via: [:get]
          end
        end
      end
    end

    # this allows us to use namespaced paths without namespacing the routes
    def unnest_namespace
      current_scope = @scope.dup
      yield
    ensure
      @scope = current_scope
    end

    # ignore error about omniauth/multiple model support
    def set_omniauth_path_prefix!(path_prefix)
      ::OmniAuth.config.path_prefix = path_prefix
    end
  end
end
