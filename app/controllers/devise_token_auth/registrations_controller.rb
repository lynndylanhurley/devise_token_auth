module DeviseTokenAuth
  class RegistrationsController < Devise::RegistrationsController
    include Devise::Controllers::Helpers
    include DeviseTokenAuth::Concerns::SetUserByToken

    prepend_before_filter :require_no_authentication, :only => [ :create, :destroy, :update ]
    before_action :configure_devise_token_auth_permitted_parameters

    skip_before_filter :set_user_by_token, :only => [:create]
    skip_before_filter :authenticate_scope!, :only => [:destroy, :update]
    skip_after_filter :update_auth_header, :only => [:create, :destroy]

    respond_to :json

    def create
      @resource            = resource_class.new(sign_up_params)
      @resource.uid        = sign_up_params[:email]
      @resource.provider   = "email"

      begin
        if @resource.save
          render json: {
            status: 'success',
            data:   @resource.as_json
          }
        else
          clean_up_passwords @resource
          render json: {
            status: 'error',
            data:   @resource,
            errors: @resource.errors
          }, status: 403
        end
      rescue ActiveRecord::RecordNotUnique
        clean_up_passwords @resource
        render json: {
          status: 'error',
          data:   @resource,
          errors: ["An account already exists for #{@resource.email}"]
        }, status: 403
      end
    end

    def update
      if @user
        if @user.update_attributes(account_update_params)
          render json: {
            status: 'success',
            data:   @user.as_json
          }
        else
          render json: {
            status: 'error',
            errors: @user.errors
          }, status: 403
        end
      else
        render json: {
          status: 'error',
          errors: ["User not found."]
        }, status: 404
      end
    end

    def destroy
      if @user
        @user.destroy

        render json: {
          status: 'success',
          message: "Account with uid #{@user.uid} has been destroyed."
        }
      else
        render json: {
          status: 'error',
          errors: ["Unable to locate account for destruction."]
        }, status: 404
      end
    end

    def sign_up_params
      params.permit(devise_parameter_sanitizer.for(:sign_up))
    end

    def account_update_params
      params.permit(devise_parameter_sanitizer.for(:account_update))
    end

    def configure_devise_token_auth_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :confirm_success_url
    end
  end
end
