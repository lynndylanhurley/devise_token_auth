module DeviseTokenAuth
  class PasswordsController < DeviseTokenAuth::ApplicationController
    before_action :set_user_by_token, :only => [:update]
    skip_after_action :update_auth_header, :only => [:create, :edit]

    # this action is responsible for generating password reset tokens and
    # sending emails
    def create
      unless resource_params[:email]
        return render_create_error_missing_email
      end

      # give redirect value from params priority
      @redirect_url = params[:redirect_url]

      # fall back to default value if provided
      @redirect_url ||= DeviseTokenAuth.default_password_reset_url

      unless @redirect_url
        return render_create_error_missing_redirect_url
      end

      # if whitelist is set, validate redirect_url against whitelist
      if DeviseTokenAuth.redirect_whitelist
        unless DeviseTokenAuth::Url.whitelisted?(@redirect_url)
          return render_create_error_not_allowed_redirect_url
        end
      end

      @email = get_case_insensitive_field_from_resource_params(:email)
      @resource = find_resource(:uid, @email)

      if @resource
        yield @resource if block_given?
        @resource.send_reset_password_instructions({
          email: @email,
          provider: 'email',
          redirect_url: @redirect_url,
          client_config: params[:config_name]
        })

        if @resource.errors.empty?
          return render_create_success
        else
          render_create_error @resource.errors
        end
      else
        if Devise.paranoid
          return render_create_success
        else
          @errors = [I18n.t("devise_token_auth.passwords.user_not_found", email: @email)]
          @error_status = 404
        end
      end

      if @errors
      end
    end

    # this is where users arrive after visiting the password reset confirmation link
    def edit
      # if a user is not found, return nil
      @resource = with_reset_password_token(resource_params[:reset_password_token])

      if @resource && @resource.reset_password_period_valid?
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + @resource.token_lifespan).to_i

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        # ensure that user is confirmed
        @resource.skip_confirmation! if confirmable_enabled? && !@resource.confirmed_at

        # allow user to change password once without current_password
        @resource.allow_password_change = true if recoverable_enabled?

        @resource.save!

        yield @resource if block_given?

        redirect_header_options = {reset_password: true}
        redirect_headers = build_redirect_headers(token,
                                                  client_id,
                                                  redirect_header_options)
        redirect_to(@resource.build_auth_url(params[:redirect_url],
                                             redirect_headers))
      else
        render_edit_error
      end
    end

    def update
      # make sure user is authorized
      unless @resource
        return render_update_error_unauthorized
      end

      # make sure account doesn't use oauth2 provider
      unless @resource.provider == 'email'
        return render_update_error_password_not_required
      end

      # ensure that password params were sent
      unless password_resource_params[:password] && password_resource_params[:password_confirmation]
        return render_update_error_missing_password
      end

      if @resource.send(resource_update_method, password_resource_params)
        @resource.allow_password_change = false if recoverable_enabled?
        @resource.save!

        yield @resource if block_given?
        return render_update_success
      else
        return render_update_error
      end
    end

    protected

    def resource_update_method
      allow_password_change = recoverable_enabled? && @resource.allow_password_change == true
      if DeviseTokenAuth.check_current_password_before_update == false || allow_password_change
        "update_attributes"
      else
        "update_with_password"
      end
    end

    def render_create_error_missing_email
      render_error(401, I18n.t("devise_token_auth.passwords.missing_email"))
    end

    def render_create_error_missing_redirect_url
      render_error(401, I18n.t("devise_token_auth.passwords.missing_redirect_url"))
    end

    def render_create_error_not_allowed_redirect_url
      response = {
        status: 'error',
        data:   resource_data
      }
      message = I18n.t("devise_token_auth.passwords.not_allowed_redirect_url", redirect_url: @redirect_url)
      render_error(422, message, response)
    end

    def render_create_success
      render json: {
        success: true,
        message: I18n.t("devise_token_auth.passwords.sended", email: @email)
      }
    end

    def render_create_error(errors)
      render json: {
        success: false,
        errors: errors,
      }, status: 400
    end

    def render_edit_error
      raise ActionController::RoutingError.new('Not Found')
    end

    def render_update_error_unauthorized
      render_error(401, 'Unauthorized')
    end

    def render_update_error_password_not_required
      render_error(422, I18n.t("devise_token_auth.passwords.password_not_required", provider: @resource.provider.humanize))
    end

    def render_update_error_missing_password
      render_error(422, I18n.t("devise_token_auth.passwords.missing_passwords"))
    end

    def render_update_success
      render json: {
        success: true,
        data: resource_data,
        message: I18n.t("devise_token_auth.passwords.successfully_updated")
      }
    end

    def render_update_error
      return render json: {
        success: false,
        errors: resource_errors
      }, status: 422
    end

    private

    def resource_params
      params.permit(:email, :reset_password_token)
    end

    def password_resource_params
      params.permit(*params_for_resource(:account_update))
    end

    def with_reset_password_token token
      recoverable = resource_class.with_reset_password_token(token)

      recoverable.reset_password_token = token if recoverable && recoverable.reset_password_token.present?
      recoverable
    end

    def render_not_found_error
      render_error(404, I18n.t("devise_token_auth.passwords.user_not_found", email: @email))
    end
  end
end
