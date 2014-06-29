# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
module DeviseTokenAuth
  class SessionsController < Devise::SessionsController
    prepend_before_filter :require_no_authentication, :only => [:create]
    include Devise::Controllers::Helpers

    respond_to :json

    def create
      resource = User.find_by_email(resource_params[:email])

      unless resource and valid_params? and resource.valid_password?(params[:password])
        render json: {
          success: false,
          errors: ["Invalid login credentials. Please try again."]
        }, status: 401

      else
        sign_in(:user, resource, store: false)

        render json: {
          success: true,
          data: resource.as_json
        }
      end
    end

    def destroy
      sign_out(resource_name)

      render json: {
        success:true
      }
    end

    def valid_params?
      params[:password] && params[:email]
    end

    def resource_params
      params.permit(:email, :password)
    end
  end
end
