module DeviseTokenAuth::Concerns::SetUserByToken
  extend ActiveSupport::Concern
  include DeviseTokenAuth::Concerns::ResourceFinder

  included do
    before_action :set_request_start
    after_action :update_auth_header
  end

  protected

  # keep track of request duration
  def set_request_start
    @request_started_at = Time.now
    @used_auth_by_token = true

    # initialize instance variables
    @client_id = nil
    @resource = nil
    @token = nil
    @is_batch_request = nil
  end

  def ensure_pristine_resource
    if @resource.changed?
      # Stash pending changes in the resource before reloading.
      changes = @resource.changes
      @resource.reload
    end
    yield
  ensure
    # Reapply pending changes
    @resource.assign_attributes(changes) if changes
  end

  # user auth
  def set_user_by_token(mapping=nil)
    # determine target authentication class
    rc = resource_class(mapping)

    # no default user defined
    return unless rc

    # gets the headers names, which was set in the initialize file
    uid_name = DeviseTokenAuth.headers_names[:'uid']
    access_token_name = DeviseTokenAuth.headers_names[:'access-token']
    client_name = DeviseTokenAuth.headers_names[:'client']

    # parse header for values necessary for authentication
    uid        = request.headers[uid_name] || params[uid_name]
    @token     ||= request.headers[access_token_name] || params[access_token_name]
    @client_id ||= request.headers[client_name] || params[client_name]

    # client_id isn't required, set to 'default' if absent
    @client_id ||= 'default'

    # check for an existing user, authenticated via warden/devise, if enabled
    if DeviseTokenAuth.enable_standard_devise_support
      devise_warden_user = warden.user(rc.to_s.underscore.to_sym)
      if devise_warden_user && devise_warden_user.tokens[@client_id].nil?
        @used_auth_by_token = false
        @resource = devise_warden_user
        @resource.create_new_auth_token
      end
    end

    # user has already been found and authenticated
    return @resource if @resource && @resource.is_a?(rc)

    # ensure we clear the client_id
    if !@token
      @client_id = nil
      return
    end

    return false unless @token

    # mitigate timing attacks by finding by uid instead of auth token
    user = uid && rc.find_by(uid: uid)

    if user && user.valid_token?(@token, @client_id)
      # sign_in with bypass: true will be deprecated in the next version of Devise
      if self.respond_to?(:bypass_sign_in) && DeviseTokenAuth.bypass_sign_in
        bypass_sign_in(user, scope: :user)
      else
        sign_in(:user, user, store: false, event: :fetch, bypass: DeviseTokenAuth.bypass_sign_in)
      end
      return @resource = user
    else
      # zero all values previously set values
      @client_id = nil
      return @resource = nil
    end
  end

  def update_auth_header
    # cannot save object if model has invalid params
    return unless defined?(@resource) && @resource && @resource.valid? && @client_id

    # Generate new client_id with existing authentication
    @client_id = nil unless @used_auth_by_token

    if @used_auth_by_token && !DeviseTokenAuth.change_headers_on_each_request
      # should not append auth header if @resource related token was
      # cleared by sign out in the meantime
      return if @resource.reload.tokens[@client_id].nil?

      auth_header = @resource.build_auth_header(@token, @client_id)

      # update the response header
      response.headers.merge!(auth_header)

    else

      ensure_pristine_resource do
        # Lock the user record during any auth_header updates to ensure
        # we don't have write contention from multiple threads
        @resource.with_lock do
          # should not append auth header if @resource related token was
          # cleared by sign out in the meantime
          return if @used_auth_by_token && @resource.tokens[@client_id].nil?

          # determine batch request status after request processing, in case
          # another processes has updated it during that processing
          @is_batch_request = is_batch_request?(@resource, @client_id)

          auth_header = {}

          # extend expiration of batch buffer to account for the duration of
          # this request
          if @is_batch_request
            auth_header = @resource.extend_batch_buffer(@token, @client_id)

            # Do not return token for batch requests to avoid invalidated
            # tokens returned to the client in case of race conditions.
            # Use a blank string for the header to still be present and
            # being passed in a XHR response in case of
            # 304 Not Modified responses.
            auth_header[DeviseTokenAuth.headers_names[:"access-token"]] = ' '
            auth_header[DeviseTokenAuth.headers_names[:"expiry"]] = ' '

          # update Authorization response header with new token
          else
            auth_header = @resource.create_new_auth_token(@client_id)
          end

          # update the response header
          response.headers.merge!(auth_header)

        end # end lock
      end # end ensure_pristine_resource
    end

  end

  private


  def is_batch_request?(user, client_id)
    !params[:unbatch] &&
    user.tokens[client_id] &&
    user.tokens[client_id]['updated_at'] &&
    Time.parse(user.tokens[client_id]['updated_at']) > @request_started_at - DeviseTokenAuth.batch_request_buffer_throttle
  end
end
