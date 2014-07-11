DeviseTokenAuth.setup do |config|
  # tokens are changed after each request by default. change the following
  # param to false if you would like to allow tokens to be re-used until they
  # expire
  config.change_headers_on_each_request = true
end
