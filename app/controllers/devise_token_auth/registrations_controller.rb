module DeviseTokenAuth
  class RegistrationsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, :only => [:destroy, :update]
    skip_after_filter :update_auth_header, :only => [:create, :destroy]

    respond_to :json

    def create
      @resource            = resource_class.new(sign_up_params)
      @resource.uid        = sign_up_params[:email]
      @resource.provider   = "email"

      # success redirect url is required
      unless params[:confirm_success_url]
        return render json: {
          status: 'error',
          data:   @resource,
          errors: ["Missing `confirm_success_url` param."]
        }, status: 403
      end

      begin
        if @resource.save
          @resource.send_confirmation_instructions({
            client_config: params[:config_name],
            redirect_url: params[:confirm_success_url]
          })

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
  end
end
