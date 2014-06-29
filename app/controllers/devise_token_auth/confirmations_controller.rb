module DeviseTokenAuth
  class ConfirmationsController < Devise::ConfirmationsController
    include Devise::Controllers::Helpers

    def show
      @user = User.confirm_by_token(params[:confirmation_token])
      if @user
        sign_in @user
        redirect_to generate_url(@user.confirm_success_url, {
          token: @user.auth_token,
          email: @user.email
        })
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def generate_url(url, params = {})
      uri = URI(url)
      uri.query = params.to_query
      uri.to_s
    end
  end
end
