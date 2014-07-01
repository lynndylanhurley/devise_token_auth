module DeviseTokenAuth
  class RegistrationsController < Devise::RegistrationsController
    include Devise::Controllers::Helpers

    prepend_before_filter :require_no_authentication, :only => [ :create ]

    respond_to :json

    def create
      @resource            = User.new(resource_params)
      @resource.uid        = resource_params[:email]
      @resource.provider   = "email"

      if @resource.save
        render json: {
          status: 'success',
          data:   @resource.as_json
        }
      else
        clean_up_passwords @resource
        render status: 403, json: {
          status: 'error',
          data:   @resource.as_json,
          errors: @resource.errors.full_messages
        }
      end
    end

    def resource_params
      params.permit(:email, :password, :password_confirmation, :confirm_success_url, :confirm_error_url)
    end
  end
end
