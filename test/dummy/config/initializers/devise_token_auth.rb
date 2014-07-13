DeviseTokenAuth.setup do |config|
  config.change_headers_on_each_request = true
  config.token_lifespan                 = 2.weeks
  config.batch_request_throttle         = 2.seconds
end
