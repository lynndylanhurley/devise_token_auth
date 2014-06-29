module DeviseTokenAuth
  class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :null_session
    skip_before_filter :verify_authenticity_token

    prepend_before_action :validate_user

    # user auth
    def validate_user
      auth_header = request.headers["Authorization"]

      # missing auth token
      return false if not auth_header

      token = auth_header[/token=(.*?) /,1]
      email = auth_header[/email=(.*?)$/,1]

      @user = @current_user = User.where(
        email: email,
        auth_token: token
      ).first

      # invalid auth token
      return if not @user
      return if not @user.auth_token == token

      # sign in user, don't create session
      sign_in(@user, store: false)
    end
  end
end
