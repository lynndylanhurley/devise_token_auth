module DeviseTokenAuth
  class PasswordsController < Devise::PasswordsController
    include Devise::Controllers::Helpers
    include DeviseTokenAuth::Concerns::SetUserByToken

    skip_before_filter :set_user_by_token, :only => [:create, :edit]
    skip_after_filter :update_auth_header, :only => [:create, :edit]

    # this action is responsible for generating password reset tokens and
    # sending emails
    def create
      unless resource_params[:email]
        return render json: {
          success: false,
          errors: ['You must provide an email address.']
        }, status: 401
      end

      unless resource_params[:redirect_url]
        return render json: {
          success: false,
          errors: ['Missing redirect url.']
        }, status: 401
      end

      @user = resource_class.where({
        email: resource_params[:email],
        provider: 'email'
      }).first

      errors = nil

      if @user
        @user.update_attributes({
          reset_password_redirect_url: resource_params[:redirect_url]
        })

        @user = resource_class.send_reset_password_instructions({
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
          errors = @user.errors
        end
      else
        errors = ["Unable to find user with email '#{resource_params[:email]}'."]
      end

      if errors
        render json: {
          success: false,
          errors: errors
        }, status: 400
      end
    end


    # this is where users arrive after visiting the email confirmation link
    def edit
      @user = resource_class.reset_password_by_token({
        reset_password_token: resource_params[:reset_password_token]
      })

      if @user and @user.id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

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
      # make sure user is authorized
      unless @user
        return render json: {
          success: false,
          errors: ['Unauthorized']
        }, status: 401
      end

      # make sure account doesn't use oauth2 provider
      unless @user.provider == 'email'
        return render json: {
          success: false,
          errors: ["This account does not require a password. Sign in using "+
                   "your #{@user.provider.humanize} account instead."]
        }, status: 422
      end

      # ensure that password params were sent
      unless resource_params[:password] and resource_params[:password_confirmation]
        return render json: {
          success: false,
          errors: ['You must fill out the fields labeled "password" and "password confirmation".']
        }, status: 422
      end

      if @user.update_attributes(resource_params)
        return render json: {
          success: true,
          data: {
            user: @user,
            message: "Your password has been successfully updated."
          }
        }
      else
        return render json: {
          success: false,
          errors: @user.errors
        }, status: 422
      end
    end


    def resource_params
      params.permit(:email, :password, :password_confirmation, :reset_password_token, :redirect_url)
    end
  end
end
