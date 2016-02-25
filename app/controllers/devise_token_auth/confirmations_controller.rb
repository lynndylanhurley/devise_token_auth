module DeviseTokenAuth
  class ConfirmationsController < DeviseTokenAuth::ApplicationController

    before_action :setup_confirmation, :only => [:create, :show]

    def create
      return unless @successful_confirmation
      yield if block_given?

      update_auth_header
      render_create_success
    end

    def show
      return unless @successful_confirmation
      yield if block_given?

      redirect_to(@resource.build_auth_url(params[:redirect_url], {
        token:                        @token,
        client_id:                    @client_id,
        account_confirmation_success: true,
        config:                       params[:config]
      }))
    end

    private

      def setup_confirmation
        @successful_confirmation = false

        @resource = get_resource

        render_create_error_invalid_resource && return \
          unless @resource.present?

        create_resource_token

        render_create_error && return \
          unless @resource.save

        @successful_confirmation = true
      end

      def get_resource
        resource = resource_class.confirm_by_token(params[:confirmation_token])
        resource = nil unless resource.try(:id).present?
        resource
      end

      def create_resource_token
        # create client id and token
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        # store client + token in user's token hash
        @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }
      end

      def render_create_success
        render json: {
          success: true,
          data: @resource.token_validation_response
        }
      end

      def render_create_error_invalid_resource
        render json: {
          success: false,
          errors: [I18n.t("devise_token_auth.confirmations.bad_token")]
        }, status: 401
      end

      def render_create_error
        render json: {
          success: false,
          errors: resource_errors
        }, status: 422
      end

  end
end
