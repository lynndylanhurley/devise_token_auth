## Model Concerns

##### DeviseTokenAuth::Concerns::User

Typical use of this gem will not require the use of any of the following model methods. All authentication should be handled invisibly by the [controller concerns](controller_methods.md).

Models that include the `DeviseTokenAuth::Concerns::User` concern will have access to the following public methods (read the above section for context on `token` and `client`):

* **`valid_token?`**: check if an authentication token is valid. Accepts a `token` and `client` as arguments. Returns a boolean.

  **Example**:
  ~~~ruby
  # extract token + client_id from auth header
  client_id = request.headers['client']
  token = request.headers['access-token']

  @resource.valid_token?(token, client_id)
  ~~~

* **`create_new_auth_token`**: creates a new auth token with all of the necessary metadata. Accepts `client` as an optional argument. Will generate a new `client` if none is provided. Returns the authentication headers that should be sent by the client as an object.

  **Example**:
  ~~~ruby
  # extract client_id from auth header
  client_id = request.headers['client']

  # update token, generate updated auth headers for response
  new_auth_header = @resource.create_new_auth_token(client_id)

  # update response with the header that will be required by the next request
  response.headers.merge!(new_auth_header)
  ~~~

* **`build_auth_header`**: generates the auth header that should be sent to the client with the next request. Accepts `token` and `client` as arguments. Returns a string.

  **Example**:
  ~~~ruby
  # create client id and token
  client_id = SecureRandom.urlsafe_base64(nil, false)
  token     = SecureRandom.urlsafe_base64(nil, false)

  # store client + token in user's token hash
  @resource.tokens[client_id] = {
    token: BCrypt::Password.create(token),
    expiry: (Time.zone.now + @resource.token_lifespan).to_i
  }

  # generate auth headers for response
  new_auth_header = @resource.build_auth_header(token, client_id)

  # update response with the header that will be required by the next request
  response.headers.merge!(new_auth_header)
  ~~~
