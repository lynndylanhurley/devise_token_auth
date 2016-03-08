module DeviseTokenAuth
  class TokenValidationsController < DeviseTokenAuth::ApplicationController
    skip_before_action :assert_is_devise_resource!, :only => [:validate_token]
    before_action :set_user_by_token, :only => [:validate_token]

    def validate_token
      # @resource will have been set by set_user_token concern
      if @resource
        yield if block_given?
        render_validate_token_success
      else
        render_validate_token_error
      end
    end

    protected

    def render_validate_token_success
      case response_format
      when :custom    # custom JSON response format
        render json: {
          success: true,
          data: @resource.token_validation_response
        }
      when :json_api  # JSON API specification compliant response format
        # TODO: JSON API response not yet implemented
      else
        raise_unknown_format_argument_error
      end
    end

    def render_validate_token_error
      case response_format
      when :custom    # custom JSON response format
        render json: {
          success: false,
          errors: [I18n.t("devise_token_auth.token_validations.invalid")]
        }, status: 401
      when :json_api  # JSON API specification compliant response format
        # TODO: JSON API response not yet implemented
      else
        raise_unknown_format_argument_error
      end
    end
  end
end
