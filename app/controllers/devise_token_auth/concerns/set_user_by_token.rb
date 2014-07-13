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

    # parse header for values necessary for authentication
    uid        = auth_header[/uid=(.*?)$/,1]
    @token     = auth_header[/token=(.*?) /,1]
    @client_id = auth_header[/client=(.*?) /,1]

    # client_id isn't required, set to 'default' if absent
    @client_id ||= 'default'

    # mitigate timing attacks by finding by uid instead of auth token
    @user = @current_user = uid && User.find_by_uid(uid)

    if @user && @user.valid_token?(@token, @client_id)
      sign_in(:user, @user, store: false, bypass: true)

      # check this now so that the duration of the request itself doesn't eat
      # away the buffer
      @is_batch_request = is_batch_request?(@user, @client_id)

    else
      # zero all values previously set values
      @user = @current_user = @is_batch_request = nil
    end
  end


  def update_auth_header

    auth_header = nil
    if not DeviseTokenAuth.change_headers_on_each_request
      auth_header = @user.build_auth_header(@token, @client_id)

    # extend expiration of batch buffer to account for the duration of
    # this request
    elsif @is_batch_request and @client_id and @user
      auth_header = @user.extend_batch_buffer(@token, @client_id)

    # update Authorization response header with new token
    elsif @user and @client_id
      auth_header = @user.create_new_auth_token(@client_id)
    end

    response.headers["Authorization"] = auth_header if auth_header
  end


  private

  def is_batch_request?(user, client_id)
    user.tokens[client_id] and
    user.tokens[client_id]['updated_at'] and
    user.tokens[client_id]['updated_at'] > Time.now - DeviseTokenAuth.batch_request_buffer_throttle
  end
end
