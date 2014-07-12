module DeviseTokenAuth
  class Engine < ::Rails::Engine
    isolate_namespace DeviseTokenAuth
  end

  mattr_accessor :change_headers_on_each_request,
                 :token_lifespan

  self.change_headers_on_each_request = true
  self.token_lifespan                 = 2.weeks

  def self.setup(&block)
    yield self
  end
end
