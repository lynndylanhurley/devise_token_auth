module DeviseTokenAuth
  class OmniauthCallbacksController < DeviseTokenAuth::ApplicationController
    skip_before_filter :set_user_by_token
    skip_after_filter :update_auth_header

    # intermediary route for successful omniauth authentication. omniauth does
    # not support multiple models, so we must resort to this terrible hack.
    def redirect_callbacks
      # derive target redirect route from 'resource_class' param, which was set
      # before authentication.
      devise_mapping = request.env['omniauth.params']['resource_class'].underscore.to_sym
      redirect_route = "/#{Devise.mappings[devise_mapping].as_json["path"]}/#{params[:provider]}/callback"

      # preserve omniauth info for success route
      session['dta.omniauth.auth'] = request.env['omniauth.auth']
      session['dta.omniauth.params'] = request.env['omniauth.params']

      redirect_to redirect_route
    end

    def omniauth_success
      # find or create user by provider and provider uid
      @resource = resource_class.where({
        uid:      auth_hash['uid'],
        provider: auth_hash['provider']
      }).first_or_initialize

      # create token info
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token     = SecureRandom.urlsafe_base64(nil, false)
      @expiry    = (Time.now + DeviseTokenAuth.token_lifespan).to_i

      @auth_origin_url = generate_url(omniauth_params['auth_origin_url'], {
        token:     @token,
        client_id: @client_id,
        uid:       @resource.uid,
        expiry:    @expiry
      })

      # set crazy password for new oauth users. this is only used to prevent
      # access via email sign-in.
      unless @resource.id
        p = SecureRandom.urlsafe_base64(nil, false)
        @resource.password = p
        @resource.password_confirmation = p
      end

      @resource.tokens[@client_id] = {
        token: BCrypt::Password.create(@token),
        expiry: @expiry
      }

      # sync user info with provider, update/generate auth token
      assign_provider_attrs(@resource, auth_hash)

      # assign any additional (whitelisted) attributes
      extra_params = whitelisted_params
      @resource.assign_attributes(extra_params) if extra_params

      if resource_class.devise_modules.include?(:confirmable)
        # don't send confirmation email!!!
        @resource.skip_confirmation!
      end

      sign_in(:user, @resource, store: false, bypass: false)

      @resource.save!

      # render user info to javascript postMessage communication window
      render :layout => "layouts/omniauth_response", :template => "devise_token_auth/omniauth_success"
    end


    # break out provider attribute assignment for easy method extension
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
      render :layout => "layouts/omniauth_response", :template => "devise_token_auth/omniauth_failure"
    end


    # derive allowed params from the standard devise parameter sanitizer
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

    # this will be determined differently depending on the action that calls
    # it. redirect_callbacks is called upon returning from successful omniauth
    # authentication, and the target params live in an omniauth-specific
    # request.env variable. this variable is then persisted thru the redirect
    # using our own dta.omniauth.params session var. the omniauth_success
    # method will access that session var and then destroy it immediately
    # after use.
    def omniauth_params
      if request.env['omniauth.params']
        request.env['omniauth.params']
      else
        @_omniauth_params ||= session.delete('dta.omniauth.params')
        @_omniauth_params
      end
    end

    # this sesison value is set by the redirect_callbacks method. its purpose
    # is to persist the omniauth auth hash value thru a redirect. the value
    # must be destroyed immediatly after it is accessed by omniauth_success
    def auth_hash
      @_auth_hash ||= session.delete('dta.omniauth.auth')
      @_auth_hash
    end

    # ensure that this controller responds to :devise_controller? conditionals.
    # this is used primarily for access to the parameter sanitizers.
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
