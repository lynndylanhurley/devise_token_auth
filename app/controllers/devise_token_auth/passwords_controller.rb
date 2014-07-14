module DeviseTokenAuth
  class PasswordsController < Devise::PasswordsController
    include Devise::Controllers::Helpers
    include DeviseTokenAuth::Concerns::SetUserByToken

    skip_before_filter :set_user_by_token, :only => [:create, :edit]
    skip_after_filter :update_auth_header, :only => [:create, :edit]

    # this action is responsible for generating password reset tokens and
    # sending emails
    def create
      @user = User.send_reset_password_instructions({
        email: resource_params[:email],
        provider: 'email'
      })

      if @user.errors.empty?
        @user.update_attributes({
          reset_password_redirect_url: resource_params[:redirect_url]
        })

        render json: {
          success: true,
          message: "An email has been sent to #{@user.email} containing "+
            "instructions for resetting your password."
        }
      else
        render json: {
          success: false,
          errors: @user.errors
        }, status: 400
      end
    end


    # this is where users arrive after visiting the email confirmation link
    def edit
      @user = User.reset_password_by_token({
        password_reset_token: resource_params[:password_reset_token]
      })

      if @user
        # create client id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = Time.now + DeviseTokenAuth.token_lifespan

        @user.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        @user.save!

        redirect_to(@user.build_auth_url(resource_params[:redirect_url], {
          token:          token,
          client_id:      client_id,
          reset_password: true
        }))
      else
        raise ActionController::RoutingError.new('Not Found')
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
      params.permit(:email, :password, :password_confirmation, :reset_password_token, :redirect_url)
    end
  end
end
