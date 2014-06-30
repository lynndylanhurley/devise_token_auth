module DeviseTokenAuth
  class ConfirmationsController < Devise::ConfirmationsController
    include Devise::Controllers::Helpers

    def show
      @user = User.confirm_by_token(params[:confirmation_token])
      if @user
        sign_in @user

        # generate new auth token
        token = SecureRandom.urlsafe_base64(nil, false)

        # set new token as user password
        @user.password = token
        @user.password_confirmation = token
        @user.save

        redirect_to generate_url(@user.confirm_success_url, {
          email: @user.email,
          auth_token: token
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
