module DeviseTokenAuth::Concerns::SetUserByToken
  extend ActiveSupport::Concern
  include DeviseTokenAuth::Controllers::Helpers

  included do
    after_action :update_auth_header
  end

  # user auth
  def set_user_by_token(mapping=nil)
    # determine target authentication class
    rc = resource_class(mapping)

    # no default user defined
    return unless rc

    # user has already been found and authenticated
    return @user if @user and @user.class == rc

    # parse header for values necessary for authentication
    uid        = request.headers['uid']
    @token     = request.headers['access-token']
    @client_id = request.headers['client']

    return false unless @token

    # client_id isn't required, set to 'default' if absent
    @client_id ||= 'default'

    # mitigate timing attacks by finding by uid instead of auth token
    user = uid && rc.find_by_uid(uid)

    if user && user.valid_token?(@token, @client_id)
      sign_in(:user, user, store: false, bypass: true)

      # check this now so that the duration of the request itself doesn't eat
      # away the buffer
      @is_batch_request = is_batch_request?(user, @client_id)

      return @user = user
    else
      # zero all values previously set values
      return @user = @is_batch_request = nil
    end
  end


  def update_auth_header
    # cannot save object if model has invalid params
    return unless @user and @user.valid? and @client_id

    auth_header = {}

    if not DeviseTokenAuth.change_headers_on_each_request
      auth_header = @user.build_auth_header(@token, @client_id)
      response.headers.merge!(auth_header)

    # extend expiration of batch buffer to account for the duration of
    # this request
    elsif @is_batch_request
      @user.extend_batch_buffer(@token, @client_id)

    # update Authorization response header with new token
    else
      auth_header = @user.create_new_auth_token(@client_id)
      response.headers.merge!(auth_header)
    end
  end


  def resource_class(m=nil)
    if m
      mapping = Devise.mappings[m]
    else
      mapping = Devise.mappings[resource_name] || Devise.mappings.values.first
    end

    mapping.to
  end


  private


  def is_batch_request?(user, client_id)
    user.tokens[client_id] and
    user.tokens[client_id]['updated_at'] and
    Time.parse(user.tokens[client_id]['updated_at']) > Time.now - DeviseTokenAuth.batch_request_buffer_throttle
  end
end
