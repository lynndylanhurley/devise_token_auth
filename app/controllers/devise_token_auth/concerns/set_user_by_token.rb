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

    @user = @current_user = User.where(
      uid:        uid,
      auth_token: token
    ).first

    # invalid auth token
    return if not @user
    return if not @user.auth_token

    # sign in user, don't create session
    sign_in(@user, store: false)
  end
end
