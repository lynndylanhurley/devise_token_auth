# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
module DeviseTokenAuth
  class SessionsController < Devise::SessionsController
    prepend_before_filter :require_no_authentication, :only => [:create]
    include Devise::Controllers::Helpers
    include DeviseTokenAuth::Concerns::SetUserByToken

    def create
      @user = resource_class.find_by_email(resource_params[:email])

      if @user and valid_params? and @user.valid_password?(resource_params[:password]) and @user.confirmed?
        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @user.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }
        @user.save

        render json: {
          data: @user.as_json(except: [
            :tokens, :confirm_success_url, :reset_password_redirect_url, :created_at, :updated_at
          ])
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
          errors: ["Invalid login credentials. Please try again."]
        }, status: 401
      end
    end

    def destroy
      # remove auth instance variables so that after_filter does not run
      user = remove_instance_variable(:@user) if @user
      client_id = remove_instance_variable(:@client_id) if @client_id
      remove_instance_variable(:@token) if @token

      if user and client_id and user.tokens[client_id]
        user.tokens.delete(client_id)
        user.save!

        render json: {
          success:true
        }, status: 200

      else
        render json: {
          errors: ["User was not found or was not logged in."]
        }, status: 404
      end
    end

    def valid_params?
      resource_params[:password] && resource_params[:email]
    end

    def resource_params
      params.permit(:email, :password)
    end
  end
end
