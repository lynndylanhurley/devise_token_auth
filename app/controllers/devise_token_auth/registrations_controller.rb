module DeviseTokenAuth
  class RegistrationsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, :only => [:destroy, :update]
    before_filter :validate_sign_up_params, :only => :create
    before_filter :validate_account_update_params, :only => :update
    skip_after_filter :update_auth_header, :only => [:create, :destroy]

    def create
      @resource            = resource_class.new(sign_up_params)
      @resource.provider   = "email"

      # honor devise configuration for case_insensitive_keys
      @resource.email.try :downcase! if resource_class.case_insensitive_keys.include?(:email)

      # give redirect value from params priority or fall back to default value if provided
      @redirect_url = params[:confirm_success_url] || DeviseTokenAuth.default_confirm_success_url

      # success redirect url is required
      if resource_class.devise_modules.include?(:confirmable) && !@redirect_url
        return render_create_error_missing_confirm_success_url
      end

      # if whitelist is set, validate redirect_url against whitelist
      if DeviseTokenAuth.redirect_whitelist && !DeviseTokenAuth.redirect_whitelist.include?(@redirect_url)
          return render_create_error_redirect_url_not_allowed
      end

      # override email confirmation, must be sent manually from ctrl
      resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)
      if @resource.save
        yield @resource if block_given?

        unless @resource.confirmed?
          # user will require email authentication
          @resource.send_confirmation_instructions({
            client_config: params[:config_name],
            redirect_url: @redirect_url
          })
        else
          # email auth has been bypassed, authenticate user
          @client_id = SecureRandom.urlsafe_base64(nil, false)
          @token     = SecureRandom.urlsafe_base64(nil, false)

          @resource.tokens[@client_id] = {
            token: BCrypt::Password.create(@token),
            expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
          }

          @resource.save!

          update_auth_header
        end
        render_create_success
      else
        clean_up_passwords @resource
        render_create_error
      end
    rescue ActiveRecord::RecordNotUnique
      clean_up_passwords @resource
      render_create_error_email_already_exists
    end

    def update
      if @resource
        if @resource.send(resource_update_method, account_update_params)
          yield @resource if block_given?
          render_update_success
        else
          render_update_error
        end
      else
        render_update_error_user_not_found
      end
    end

    def destroy
      if @resource
        @resource.destroy
        yield @resource if block_given?

        render_destroy_success
      else
        render_destroy_error
      end
    end

    def sign_up_params
      params.permit(devise_parameter_sanitizer.for(:sign_up))
    end

    def account_update_params
      params.permit(devise_parameter_sanitizer.for(:account_update))
    end

    protected

    def render_create_error_missing_confirm_success_url
      render json: {
        status: 'error',
        data:   @resource.as_json,
        errors: [I18n.t("devise_token_auth.registrations.missing_confirm_success_url")]
      }, status: :bad_request
    end

    def render_create_error_redirect_url_not_allowed
      render json: {
        status: 'error',
        data:   @resource.as_json,
        errors: [I18n.t("devise_token_auth.registrations.redirect_url_not_allowed", redirect_url: @redirect_url)]
      }, status: :forbidden
    end

    def render_create_success
      render json: {
        status: 'success',
        data:   @resource.as_json
      }
    end

    def render_create_error
      render json: {
        status: 'error',
        data:   @resource.as_json,
        errors: @resource.errors.to_hash.merge(full_messages: @resource.errors.full_messages)
      }, status: :unprocessable_entity
    end

    def render_create_error_email_already_exists
      render json: {
        status: 'error',
        data:   @resource.as_json,
        errors: [I18n.t("devise_token_auth.registrations.email_already_exists", email: @resource.email)]
      }, status: :unprocessable_entity
    end

    def render_update_success
      render json: {
        status: 'success',
        data:   @resource.as_json
      }
    end

    def render_update_error
      render json: {
        status: 'error',
        errors: @resource.errors.to_hash.merge(full_messages: @resource.errors.full_messages)
      }, status: :unprocessable_entity
    end

    def render_update_error_user_not_found
      render json: {
        status: 'error',
        errors: [I18n.t("devise_token_auth.registrations.user_not_found")]
      }, status: :not_found
    end

    def render_destroy_success
      render json: {
        status: 'success',
        message: I18n.t("devise_token_auth.registrations.account_with_uid_destroyed", uid: @resource.uid)
      }
    end

    def render_destroy_error
      render json: {
        status: 'error',
        errors: [I18n.t("devise_token_auth.registrations.account_to_destroy_not_found")]
      }, status: :not_found
    end

    private

    def resource_update_method
      if DeviseTokenAuth.check_current_password_before_update == :attributes
        "update_with_password"
      elsif DeviseTokenAuth.check_current_password_before_update == :password and account_update_params.has_key?(:password)
        "update_with_password"
      elsif account_update_params.has_key?(:current_password)
        "update_with_password"
      else
        "update_attributes"
      end
    end

    def validate_sign_up_params
      validate_post_data sign_up_params, I18n.t("errors.validate_sign_up_params")
    end

    def validate_account_update_params
      validate_post_data account_update_params, I18n.t("errors.validate_account_update_params")
    end

    def validate_post_data which, message
      render json: {
         status: 'error',
         errors: [message]
      }, status: :unprocessable_entity if which.empty?
    end
  end
end
