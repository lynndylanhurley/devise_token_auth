module DeviseTokenAuth
  class PasswordsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, :only => [:update]
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

      # give redirect value from params priority
      redirect_url = params[:redirect_url]

      # fall back to default value if provided
      redirect_url ||= DeviseTokenAuth.default_password_reset_url

      unless redirect_url
        return render json: {
          success: false,
          errors: ['Missing redirect url.']
        }, status: 401
      end

      # if whitelist is set, validate redirect_url against whitelist
      if DeviseTokenAuth.redirect_whitelist
        unless DeviseTokenAuth.redirect_whitelist.include?(redirect_url)
          return render json: {
            status: 'error',
            data:   @resource.as_json,
            errors: ["Redirect to #{redirect_url} not allowed."]
          }, status: 403
        end
      end

      # honor devise configuration for case_insensitive_keys
      if resource_class.case_insensitive_keys.include?(:email)
        email = resource_params[:email].downcase
      else
        email = resource_params[:email]
      end

      q = "uid = ? AND provider='email'"

      # fix for mysql default case insensitivity
      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
        q = "BINARY uid = ? AND provider='email'"
      end

      @resource = resource_class.where(q, email).first

      errors = nil
      error_status = 400

      if @resource
        @resource.send_reset_password_instructions({
          email: email,
          provider: 'email',
          redirect_url: redirect_url,
          client_config: params[:config_name]
        })

        if @resource.errors.empty?
          render json: {
            success: true,
            message: "An email has been sent to #{email} containing "+
              "instructions for resetting your password."
          }
        else
          errors = @resource.errors
        end
      else
        errors = ["Unable to find user with email '#{email}'."]
        error_status = 404
      end

      if errors
        render json: {
          success: false,
          errors: errors,
        }, status: error_status
      end
    end


    # this is where users arrive after visiting the password reset confirmation link
    def edit
      @resource = resource_class.reset_password_by_token({
        reset_password_token: resource_params[:reset_password_token]
      })

      if @resource and @resource.id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        # ensure that user is confirmed
        @resource.skip_confirmation! unless @resource.confirmed_at

        @resource.save!

        redirect_to(@resource.build_auth_url(params[:redirect_url], {
          token:          token,
          client_id:      client_id,
          reset_password: true,
          config:         params[:config]
        }))
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def update
      # make sure user is authorized
      unless @resource
        return render json: {
          success: false,
          errors: ['Unauthorized']
        }, status: 401
      end

      # make sure account doesn't use oauth2 provider
      unless @resource.provider == 'email'
        return render json: {
          success: false,
          errors: ["This account does not require a password. Sign in using "+
                   "your #{@resource.provider.humanize} account instead."]
        }, status: 422
      end

      # ensure that password params were sent
      unless password_resource_params[:password] and password_resource_params[:password_confirmation]
        return render json: {
          success: false,
          errors: ['You must fill out the fields labeled "password" and "password confirmation".']
        }, status: 422
      end

      if @resource.update_attributes(password_resource_params)
        return render json: {
          success: true,
          data: {
            user: @resource,
            message: "Your password has been successfully updated."
          }
        }
      else
        return render json: {
          success: false,
          errors: @resource.errors.to_hash.merge(full_messages: @resource.errors.full_messages)
        }, status: 422
      end
    end

    def password_resource_params
      params.permit(devise_parameter_sanitizer.for(:account_update))
    end

    def resource_params
      params.permit(:email, :password, :password_confirmation, :reset_password_token)
    end

  end
end
