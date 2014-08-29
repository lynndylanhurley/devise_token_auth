module DeviseTokenAuth
  class RegistrationsController < Devise::RegistrationsController
    include Devise::Controllers::Helpers

    prepend_before_filter :require_no_authentication, :only => [ :create ]
    before_action :configure_devise_token_auth_permitted_parameters

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

    def resource_params
      params.permit(devise_parameter_sanitizer.for(:sign_up))
    end

    def configure_devise_token_auth_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :confirm_success_url
    end
  end
end
