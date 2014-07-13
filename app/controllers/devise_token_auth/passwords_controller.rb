module DeviseTokenAuth
  class PasswordsController < DeviseTokenAuth::ApplicationController
    include Devise::Controllers::Helpers
    skip_before_filter :set_user_by_token, :only => [:create]
    skip_after_filter :update_auth_header, :only => [:create]

    def create
      # send the confirmation email
      @user = User.send_reset_password_instructions({
        email: resource_params[:email],
        provider: 'email'
      })

      if @user.errors.empty?
        render json: {
          success: true,
          message: "An email has been sent to #{@user.email} containing "+
            "instructions for resetting your password."
        }
      else
        render json: {
          success: false,
          errors: @user.errors
        }, status: 401
      end
    end


    def update
      # make sure account doesn't use oauth2 provider
      unless @user.provider == 'email'
        render json: {
          success: false,
          errors: ["This account does not require a password. Sign in using "+
                   "your #{@user.provider.humanize} account instead."]
        }, status: 401
      end

      # ensure that password params were sent
      unless resource_params[:password] and resource_params[:password_confirmaiton]
        render json: {
          success: false,
          errors: ['You must fill out the fields labeled "password" and "password confirmation".']
        }, status: 401
      end

      @user.update_attributes(resource_params)

      if @user.errors.empty?
        render json: {
          success: true,
          data: {
            user: @user,
            message: "Your password has been successfully updated."
          }
        }
      else
        render json: {
          success: false,
          errors: @user.errors
        }, status: 401
      end
    end


    def resource_params
      params.permit(:email, :password, :password_confirmation)
    end
  end
end
