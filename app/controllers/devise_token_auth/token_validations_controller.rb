module DeviseTokenAuth
  class TokenValidationsController < DeviseTokenAuth::ApplicationController
    skip_before_filter :assert_is_devise_resource!, :only => [:validate_token]
    before_filter :set_user_by_token, :only => [:validate_token]

    def validate_token
      # @user will have been set by set_user_token concern
      if @user
        render json: {
          success: true,
          data: @user.as_json(except: [
            :tokens, :confirm_success_url, :reset_password_redirect_url, :created_at, :updated_at
          ])
        }
      else
        render json: {
          success: false,
          errors: ["Invalid login credentials"]
        }, status: 401
      end
    end
  end
end
