module DeviseTokenAuth
  class PasswordsController < Devise::PasswordsController
    include Devise::Controllers::Helpers

    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      throw "Not implemented"

      if resource.errors.empty?
        render json: {
          success: true 
        }
      else
        render json: {
          success: false,
          errors: ["Something went wrong. Please contact support@healthbox.com."]
        }, status: 401
      end
    end


    def update
      self.resource = resource_class.reset_password_by_token(resource_params)
      yield resource if block_given?

      throw "Not implemented"

      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)

        render json: {
          success: true,
          data: {
            user: self.resource
          }
        }
      else
        render json: {
          success: false,
          errors: ["Something went wrong. Please contact support@healthbox.com."]
        }, status: 401
      end
    end


    def resource_params
      params.permit(:email, :password, :password_confirmation, :reset_password_token)
    end

  end
end
