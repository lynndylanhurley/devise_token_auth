module DeviseTokenAuth::Concerns::SetUserByToken
  extend ActiveSupport::Concern

  included do
    before_action :set_user_by_token
    after_action :update_auth_header
  end

  # user auth
  def set_user_by_token
    auth_header = request.headers["Authorization"]

    # missing auth token
    return false unless auth_header

    token      = auth_header[/token=(.*?) /,1]
    uid        = auth_header[/uid=(.*?)$/,1]
    @client_id = auth_header[/client=(.*?) /,1]

    @client_id ||= 'default'

    # mitigate timing attacks by finding by uid instead of auth token
    @user = @current_user = uid && User.find_by_uid(uid)

    if @user && @user.valid_token?(@client_id, token)
      sign_in(@user, store: false)
    else
      @user = @current_user = nil
    end
  end

  def update_auth_header
    if @user
      # update user's auth token (should happen on each request)
      token                    = SecureRandom.urlsafe_base64(nil, false)
      token_hash               = BCrypt::Password.create(token)
      @user.tokens[@client_id] = {
        token:  token_hash,
        expiry: Time.now + 2.weeks
      }
      @user.save

      # update Authorization response header with new token
      response.headers["Authorization"] = "token=#{token} client=#{@client_id} uid=#{@user.uid}"
    end
  end
end
