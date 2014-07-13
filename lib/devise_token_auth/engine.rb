module DeviseTokenAuth
  class Engine < ::Rails::Engine
    isolate_namespace DeviseTokenAuth
  end

  mattr_accessor :change_headers_on_each_request,
                 :token_lifespan,
                 :batch_request_buffer_throttle

  self.change_headers_on_each_request = true
  self.token_lifespan                 = 2.weeks
  self.batch_request_buffer_throttle  = 5.seconds

  def self.setup(&block)
    yield self
  end
end
