module DeviseTokenAuth
  class RegistrationsController < DeviseTokenAuth::ApplicationController
    before_action :set_user_by_token, :only => [:destroy, :update]
    before_action :validate_sign_up_params, :only => :create
    before_action :validate_account_update_params, :only => :update
    skip_after_action :update_auth_header, :only => [:create, :destroy]

    def create
      @resource            = resource_class.new(sign_up_params)
      @resource.provider   = "email"

      # honor devise configuration for case_insensitive_keys
      if resource_class.case_insensitive_keys.include?(:email)
        @resource.email = sign_up_params[:email].try :downcase
      else
        @resource.email = sign_up_params[:email]
      end

      # give redirect value from params priority
      @redirect_url = meta_params[:confirm_success_url]

      # fall back to default value if provided
      @redirect_url ||= DeviseTokenAuth.default_confirm_success_url

      # success redirect url is required
      if resource_class.devise_modules.include?(:confirmable) && !@redirect_url
        return render_create_error_missing_confirm_success_url
      end

      # if whitelist is set, validate redirect_url against whitelist
      if DeviseTokenAuth.redirect_whitelist
        unless DeviseTokenAuth.redirect_whitelist.include?(@redirect_url)
          return render_create_error_redirect_url_not_allowed
        end
      end

      begin
        # override email confirmation, must be sent manually from ctrl
        resource_class.set_callback("create", :after, :send_on_create_confirmation_instructions)
        resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)
        if @resource.save
          yield @resource if block_given?

          unless @resource.confirmed?
            # user will require email authentication
            @resource.send_confirmation_instructions({
              client_config: meta_params[:config_name],
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
      data_attributes.permit(*params_for_resource(:sign_up))
    end

    def account_update_params
      data_attributes.permit(*params_for_resource(:account_update))
    end

    protected

    def render_create_error_missing_confirm_success_url
      case response_format
      when :custom    # custom JSON response format
        render json: {
          status: 'error',
          data:   resource_data,
          errors: [I18n.t("devise_token_auth.registrations.missing_confirm_success_url")]
        }, status: 422
      when :json_api  # JSON API specification compliant response format
        render_json_api_errors [{
          source: { parameter: 'confirm_success_url' },
          detail: I18n.t("devise_token_auth.registrations.missing_confirm_success_url")
        }], 422
      else
        raise_unknown_format_argument_error
      end
    end

    def render_create_error_redirect_url_not_allowed
      case response_format
      when :custom    # custom JSON response format
        render json: {
          status: 'error',
          data:   resource_data,
          errors: [I18n.t("devise_token_auth.registrations.redirect_url_not_allowed", redirect_url: @redirect_url)]
        }, status: 422
      when :json_api  # JSON API specification compliant response format
        render_json_api_errors [{
          source: { parameter: 'redirect_url' },
          detail: I18n.t("devise_token_auth.registrations.redirect_url_not_allowed", redirect_url: @redirect_url)
        }], 422
      else
        raise_unknown_format_argument_error
      end
    end

    def render_create_success
      case response_format
      when :custom    # custom JSON response format
        render json: {
          status: 'success',
          data:   resource_data
        }
      when :json_api  # JSON API specification compliant response format
        render_json_api_data({
          type:         @resource.class.name.parameterize,
          id:           resource_data['id'].to_s,
          attributes:   resource_data.except('type', 'id')
        })
      else
        raise_unknown_format_argument_error
      end
    end

    def render_create_error
      case response_format
      when :custom    # custom JSON response format
        render json: {
          status: 'error',
          data:   resource_data,
          errors: resource_errors
        }, status: 422
      when :json_api  # JSON API specification compliant response format
        json_api_errors = @resource.errors.messages.reduce([]) do |memo, param_and_errors|
          memo << {
            source: { parameter: param_and_errors[0] },
            detail: (param_and_errors[1].join(', ') + '.').capitalize
          }
        end
        render_json_api_errors json_api_errors, 422
      else
        raise_unknown_format_argument_error
      end
    end

    def render_create_error_email_already_exists
      case response_format
      when :custom    # custom JSON response format
        render json: {
          status: 'error',
          data:   resource_data,
          errors: [I18n.t("devise_token_auth.registrations.email_already_exists", email: @resource.email)]
        }, status: 422
      when :json_api  # JSON API specification compliant response format
        render_json_api_errors [{
          source: { parameter: 'email' },
          detail: I18n.t("devise_token_auth.registrations.email_already_exists", email: @resource.email)
        }], 422
      else
        raise_unknown_format_argument_error
      end
    end

    def render_update_success
      case response_format
      when :custom    # custom JSON response format
        render json: {
          status: 'success',
          data:   resource_data
        }
      when :json_api  # JSON API specification compliant response format
        render_json_api_data({
          type:         @resource.class.name.parameterize,
          id:           resource_data['id'].to_s,
          attributes:   resource_data.except('type', 'id')
        })
      else
        raise_unknown_format_argument_error
      end
    end

    def render_update_error
      case response_format
      when :custom    # custom JSON response format
        render json: {
          status: 'error',
          errors: resource_errors
        }, status: 422
      when :json_api  # JSON API specification compliant response format
        json_api_errors = @resource.errors.messages.reduce([]) do |memo, param_and_errors|
          memo << {
            source: { parameter: param_and_errors[0] },
            detail: (param_and_errors[1].join(', ') + '.').capitalize
          }
        end
        render_json_api_errors json_api_errors, 422
      else
        raise_unknown_format_argument_error
      end
    end

    def render_update_error_user_not_found
      case response_format
      when :custom    # custom JSON response format
        render json: {
          status: 'error',
          errors: [I18n.t("devise_token_auth.registrations.user_not_found")]
        }, status: 404
      when :json_api  # JSON API specification compliant response format
        render_json_api_errors [{
          source: { parameter: 'uid' },
          detail: I18n.t("devise_token_auth.registrations.user_not_found")
        }], 404
      else
        raise_unknown_format_argument_error
      end
    end

    def render_destroy_success
      case response_format
      when :custom    # custom JSON response format
        render json: {
          status: 'success',
          message: I18n.t("devise_token_auth.registrations.account_with_uid_destroyed", uid: @resource.uid)
        }
      when :json_api  # JSON API specification compliant response format
        render_json_api_meta({
          message: I18n.t("devise_token_auth.registrations.account_with_uid_destroyed", uid: @resource.uid)
        })
      else
        raise_unknown_format_argument_error
      end
    end

    def render_destroy_error
      case response_format
      when :custom    # custom JSON response format
        render json: {
          status: 'error',
          errors: [I18n.t("devise_token_auth.registrations.account_to_destroy_not_found")]
        }, status: 404
      when :json_api  # JSON API specification compliant response format
        render_json_api_errors [{
          source: { parameter: 'uid' },
          detail: I18n.t("devise_token_auth.registrations.account_to_destroy_not_found")
        }], 404
      else
        raise_unknown_format_argument_error
      end
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
      validate_post_data sign_up_params, I18n.t("errors.messages.validate_sign_up_params")
    end

    def validate_account_update_params
      validate_post_data account_update_params, I18n.t("errors.messages.validate_account_update_params")
    end

    def validate_post_data which, message
      if which.empty?
        case response_format
        when :custom    # custom JSON response format
          render json: {
             status: 'error',
             errors: [message]
          }, status: :unprocessable_entity
        when :json_api  # JSON API specification compliant response format
          render_json_api_errors [{
            detail: message
          }], :unprocessable_entity
        else
          raise_unknown_format_argument_error
        end
      end
    end
  end
end
