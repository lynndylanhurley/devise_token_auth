module DeviseTokenAuth
  class RegistrationsController < Devise::RegistrationsController
    include Devise::Controllers::Helpers
    include DeviseTokenAuth::Concerns::SetUserByToken

    prepend_before_filter :require_no_authentication, :only => [ :create, :destroy ]
    before_action :configure_devise_token_auth_permitted_parameters

    skip_before_filter :set_user_by_token, :only => [:create]
    skip_before_filter :authenticate_scope!, :only => [:destroy]
    skip_after_filter :update_auth_header, :only => [:create, :destroy]

    respond_to :json

    def create
      @resource            = resource_class.new(resource_params)
      @resource.uid        = resource_params[:email]
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

    def resource_params
      params.permit(devise_parameter_sanitizer.for(:sign_up))
    end

    def configure_devise_token_auth_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :confirm_success_url
    end
  end
end
