module DeviseTokenAuth
  class OmniauthCallbacksController < DeviseTokenAuth::ApplicationController
    skip_before_filter :set_user_by_token
    skip_after_filter :update_auth_header

    def redirect_callbacks
      # derive redirect_to path
      devise_mapping = request.env['omniauth.params']['resource_class'].underscore.to_sym
      redirect_route = "#{Devise.mappings[devise_mapping].as_json["path_prefix"]}/#{params[:provider]}/callback"

      # preserve omniauth info for success route
      session['dta.omniauth.auth'] = request.env['omniauth.auth']
      session['dta.omniauth.params'] = request.env['omniauth.params']

      redirect_to redirect_route
    end

    def omniauth_success
      # find or create user by provider and provider uid
      @user = resource_class.where({
        uid:      auth_hash['uid'],
        provider: auth_hash['provider']
      }).first_or_initialize

      # create client id
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token     = SecureRandom.urlsafe_base64(nil, false)

      @auth_origin_url = generate_url(omniauth_params['auth_origin_url'], {
        token:     @token,
        client_id: @client_id,
        uid:       @user.uid
      })

      # set crazy password for new oauth users. this is only used to prevent
      # access via email sign-in.
      unless @user.id
        p = SecureRandom.urlsafe_base64(nil, false)
        @user.password = p
        @user.password_confirmation = p
      end

      @user.tokens[@client_id] = {
        token: BCrypt::Password.create(@token),
        expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
      }

      # sync user info with provider, update/generate auth token
      assign_provider_attrs(@user, auth_hash)

      # assign any additional (whitelisted) attributes
      extra_params = whitelisted_params
      @user.assign_attributes(extra_params) if extra_params

      # don't send confirmation email!!!
      @user.skip_confirmation!

      @user.save!

      # render user info to javascript postMessage communication window
      respond_to do |format|
        format.html { render :layout => "omniauth_response", :template => "devise_token_auth/omniauth_success" }
      end
    end

    def assign_provider_attrs(user, auth_hash)
      user.assign_attributes({
        nickname: auth_hash['info']['nickname'],
        name:     auth_hash['info']['name'],
        image:    auth_hash['info']['image'],
        email:    auth_hash['info']['email']
      })
    end

    def omniauth_failure
      @error = params[:message]

      respond_to do |format|
        format.html { render :layout => "omniauth_response", :template => "devise_token_auth/omniauth_failure" }
      end
    end

    def auth_hash
      request.env['omniauth.auth']
    end

    def whitelisted_params
      whitelist = devise_parameter_sanitizer.for(:sign_up)

      whitelist.inject({}){|coll, key|
        param = omniauth_params[key.to_s]
        if param
          coll[key] = param
        end
        coll
      }
    end

    # pull resource class from omniauth return
    def resource_class
      if omniauth_params
        omniauth_params['resource_class'].constantize
      end
    end

    def resource_name
      resource_class
    end

    def omniauth_params
      if request.env['omniauth.params']
        request.env['omniauth.params']
      else
        @_omniauth_params ||= session.delete('dta.omniauth.params')
        @_omniauth_params
      end
    end

    def auth_hash
      @_auth_hash ||= session.delete('dta.omniauth.auth')
      @_auth_hash
    end

    def assert_is_devise_resource!
      true
    end

    # necessary for access to devise_parameter_sanitizers
    def devise_mapping
      if omniauth_params
        Devise.mappings[omniauth_params['resource_class'].underscore.to_sym]
      else
        request.env['devise.mapping']
      end
    end

    def generate_url(url, params = {})
      auth_url = url

      # ensure that hash-bang is present BEFORE querystring for angularjs
      unless url.match(/#/)
        auth_url += '#'
      end

      # add query AFTER hash-bang
      auth_url += "?#{params.to_query}"

      return auth_url
    end
  end
end
