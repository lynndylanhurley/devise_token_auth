## Model Concerns

##### DeviseTokenAuth::Concerns::User

Typical use of this gem will not require the use of any of the following model methods. All authentication should be handled invisibly by the [controller concerns](controller_methods.md).

Models that include the `DeviseTokenAuth::Concerns::User` concern will have access to the following public methods (read the above section for context on `token` and `client`):

* **`valid_token?`**: check if an authentication token is valid. Accepts a `token` and `client` as arguments. Returns a boolean.

  **Example**:
  ~~~ruby
  # extract token + client from auth header
  client = request.headers['client']
  token = request.headers['access-token']

  @resource.valid_token?(token, client)
  ~~~

* **`create_new_auth_token`**: creates a new auth token with all of the necessary metadata. Accepts `client` as an optional argument. Will generate a new `client` if none is provided. Returns the authentication headers that should be sent by the client as an object.

  **Example**:
  ~~~ruby
  # extract client from auth header
  client = request.headers['client']

  # update token, generate updated auth headers for response
  new_auth_header = @resource.create_new_auth_token(client)

  # update response with the header that will be required by the next request
  response.headers.merge!(new_auth_header)
  ~~~

* **`build_auth_headers`**: generates the auth header that should be sent to the client with the next request. Accepts `token` and `client` as arguments. Returns a string.

  **Example**:
  ~~~ruby
  # create token
  token = DeviseTokenAuth::TokenFactory.create

  # store client + token in user's token hash
  @resource.tokens[token.client] = {
    token:  token.token_hash,
    expiry: token.expiry
  }

  # generate auth headers for response
  new_auth_header = @resource.build_auth_headers(token.token, token.client)

  # update response with the header that will be required by the next request
  response.headers.merge!(new_auth_header)
  ~~~
