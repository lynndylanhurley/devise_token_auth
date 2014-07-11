module DeviseTokenAuth
  class Engine < ::Rails::Engine
    isolate_namespace DeviseTokenAuth

    mattr_accessor :change_headers_on_each_request
    self.change_headers_on_each_request = true

    def self.setup(&block)
      yield self
    end
  end
end
