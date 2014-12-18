module DeviseTokenAuth
  class PasswordsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, :only => [:update]
    skip_after_filter :update_auth_header, :only => [:create, :edit]

    # this action is responsible for generating password reset tokens and
    # sending emails
    def create
      unless resource_params[:email]
        @render = Hashie::Mash.new({
          status: 'error',
          errors: ['You must provide an email address.']
        })

        return render 'devise_token_auth/passwords/create_errors', status: 401
      end

      unless params[:redirect_url]
        @render = Hashie::Mash.new({
          status: 'error',
          errors: ['Missing redirect url.']
        })

        return render 'devise_token_auth/passwords/create_errors', status: 401
      end

      # honor devise configuration for case_insensitive_keys
      if resource_class.case_insensitive_keys.include?(:email)
        email = resource_params[:email].downcase
      else
        email = resource_params[:email]
      end

      q = "uid='#{email}' AND provider='email'"

      # fix for mysql default case insensitivity
      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
        q = "BINARY uid='#{email}' AND provider='email'"
      end

      @resource = resource_class.where(q).first

      errors = nil

      if @resource
        @resource.send_reset_password_instructions({
          email: email,
          provider: 'email',
          redirect_url: params[:redirect_url],
          client_config: params[:config_name]
        })

        if @resource.errors.empty?
          @render = Hashie::Mash.new({
            status: 'success',
            message: "An email has been sent to #{email} containing "+
              'instructions for resetting your password.'
          })
          render 'devise_token_auth/passwords/create_success'
        else
          errors = @resource.errors
        end
      else
        errors = ["Unable to find user with email '#{email}'."]
      end

      if errors
        @render = Hashie::Mash.new({
          success: false,
          errors: errors
        })

        render 'devise_token_auth/passwords/create_errors', status: 400
      end
    end


    # this is where users arrive after visiting the email confirmation link
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
        @render = Hashie::Mash.new({
          status: 'error',
          errors: ['Unauthorized']
        })
        render 'devise_token_auth/passwords/update_errors', status: 401
      end

      # make sure account doesn't use oauth2 provider
      unless @resource.provider == 'email'
        @render = Hashie::Mash.new({
          status: 'error',
          errors: ['This account does not require a password. Sign in using '+
                   "your #{@resource.provider.humanize} account instead."]
        })

        render 'devise_token_auth/passwords/update_errors', status: 422
      end

      # ensure that password params were sent
      unless password_resource_params[:password] and password_resource_params[:password_confirmation]
        @render = Hashie::Mash.new({
          status: 'error',
          errors: ['You must fill out the fields labeled "password" and "password confirmation".']
        })

        render 'devise_token_auth/passwords/update_errors', status: 422
      end

      if @resource.update_attributes(password_resource_params)
        @render = Hashie::Mash.new({
          status: 'success',
          data: {
            user: @resource,
            message: 'Your password has been successfully updated.'
          }
        })

        render 'devise_token_auth/passwords/update_success'
      else
        @render = Hashie::Mash.new({
          success: false,
          errors: @resource.errors
        })

        render 'devise_token_auth/passwords/update_errors', status: 422
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
