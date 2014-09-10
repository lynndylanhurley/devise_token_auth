module DeviseTokenAuth
  class AuthController < DeviseTokenAuth::ApplicationController
    respond_to :json
    skip_after_filter :update_auth_header, :only => [:omniauth_success, :omniauth_failure]
    skip_before_filter :assert_is_devise_resource!, :only => [:validate_token]

    def validate_token
      # @user will have been set by set_user_token concern
      if @user
        render json: {
          success: true,
          data: @user.as_json(except: [
            :tokens, :confirm_success_url, :reset_password_redirect_url, :created_at, :updated_at
          ])
        }
      else
        render json: {
          success: false,
          errors: ["Invalid login credentials"]
        }, status: 401
      end
    end

    def omniauth_success

      # find or create user by provider and provider uid
      @user = resource_name.where({
        uid:      auth_hash['uid'],
        provider: auth_hash['provider']
      }).first_or_initialize

      # create client id
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token     = SecureRandom.urlsafe_base64(nil, false)

      @auth_origin_url = generate_url(request.env['omniauth.params']['auth_origin_url'], {
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
      @user.assign_attributes({
        nickname: auth_hash['info']['nickname'],
        name:     auth_hash['info']['name'],
        image:    auth_hash['info']['image'],
        email:    auth_hash['info']['email']
      })

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
        param = request.env['omniauth.params'][key.to_s]
        if param
          coll[key] = param
        end
        coll
      }
    end

    def devise_controller?
      true
    end

    # pull resource class from omniauth return
    def resource_name
      if request.env['omniauth.params']
        request.env['omniauth.params']['resource_class'].constantize
      else
        super
      end
    end

    # necessary for access to devise_parameter_sanitizers
    def devise_mapping
      if request.env['omniauth.params']
        Devise.mappings[request.env['omniauth.params']['resource_class'].underscore.to_sym]
      else
        request.env['devise.mapping']
      end
    end

    def generate_url(url, params = {})
      uri = URI(url)
      uri.query = params.to_query
      uri.to_s
    end
  end
end
