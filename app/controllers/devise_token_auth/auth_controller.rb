module DeviseTokenAuth
  class AuthController < DeviseTokenAuth::ApplicationController
    respond_to :json

    skip_after_filter :update_auth_header, :only => [:omniauth_success, :omniauth_failure]

    def validate_token
      # @user will have been set by set_user_token concern
      if @user
        render json: {
          success: true,
          data: @user.as_json
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
      @user = User.where({
        uid:      auth_hash['uid'],
        provider: auth_hash['provider'],
        email:    auth_hash['info']['email'],
      }).first_or_initialize

      @token = SecureRandom.urlsafe_base64(nil, false)

      # sync user info with provider, update/generate auth token
      @user.update_attributes({
        nickname:              auth_hash['info']['nickname'],
        name:                  auth_hash['info']['name'],
        image:                 auth_hash['info']['image'],
        password:              @token,
        password_confirmation: @token
      })

      # render user info to javascript postMessage communication window
      respond_to do |format|
        format.html { render :layout => "omniauth_response", :template => "devise_token_auth/omniauth_success" }
      end
    end

    def omniauth_failure
      render json: {
        success: false,
        errors: [params[:message]]
      }, status: 500
    end

    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
