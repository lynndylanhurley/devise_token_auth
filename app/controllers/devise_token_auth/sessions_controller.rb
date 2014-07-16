# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
module DeviseTokenAuth
  class SessionsController < Devise::SessionsController
    prepend_before_filter :require_no_authentication, :only => [:create]
    include Devise::Controllers::Helpers
    include DeviseTokenAuth::Concerns::SetUserByToken

    respond_to :json

    def create
      @user = resource_class.find_by_email(resource_params[:email])

      if @user and valid_params? and @user.valid_password?(resource_params[:password]) and @user.confirmed?
        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @user.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: Time.now + DeviseTokenAuth.token_lifespan
        }
        @user.save

        render json: {
          success: true,
          data: @user.as_json
        }

      elsif @user and not @user.confirmed?
        render json: {
          success: false,
          errors: [
            "A confirmation email was sent to your account at #{@user.email}. "+
            "You must follow the instructions in the email before your account "+
            "can be activated"
          ]
        }, status: 401

      else
        render json: {
          success: false,
          errors: ["Invalid login credentials. Please try again."]
        }, status: 401
      end
    end

    def destroy
      sign_out(resource_name)

      render json: {
        success:true
      }
    end

    def valid_params?
      resource_params[:password] && resource_params[:email]
    end

    def resource_params
      params.permit(:email, :password)
    end
  end
end
