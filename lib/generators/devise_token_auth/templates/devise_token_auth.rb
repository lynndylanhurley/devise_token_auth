DeviseTokenAuth.setup do |config|
  # By default the authorization headers will change after each request. The
  # client is responsible for keeping track of the changing tokens. Change
  # this to false to prevent the Authorization header from changing after
  # each request.
  #config.change_headers_on_each_request = true

  # By default, users will need to re-authenticate after 2 weeks. This setting
  # determines how long tokens will remain valid after they are issued.
  #config.token_lifespan = 2.weeks

  # Sometimes it's necessary to make multiple requests in rapid succession.
  # It's impossible to update the auth header for each of these requests
  # because the client may have initiated all of them simultaneously (before
  # the first request has finished). The solution is to consider a rapid
  # succession of requests from a single client to be a single batch request.
  # The default time buffer for what is considered to be a batch request is
  # 2 seconds. Change that setting here.
  #config.batch_request_throttle = 2.seconds
end
