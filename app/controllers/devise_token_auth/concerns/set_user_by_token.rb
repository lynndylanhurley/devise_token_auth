module DeviseTokenAuth::Concerns::SetUserByToken
  extend ActiveSupport::Concern

  included do
    before_action :set_user_by_token
  end

  # user auth
  def set_user_by_token
    auth_header = request.headers["Authorization"]

    # missing auth token
    return false if not auth_header

    token = auth_header[/token=(.*?) /,1]
    uid   = auth_header[/uid=(.*?)$/,1]

    # mitigate timing attacks by finding by uid instead of auth token
    @user = @current_user = uid && User.find_by_uid(uid)

    # invalid auth token
    return if not @user
    return if not @user.auth_token == token

    # sign in user, don't create session
    sign_in(@user, store: false)
  end
end
