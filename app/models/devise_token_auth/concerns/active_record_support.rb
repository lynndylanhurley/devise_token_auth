module DeviseTokenAuth::Concerns::ActiveRecordSupport
  extend ActiveSupport::Concern

  included do
    if Rails::VERSION::MAJOR >= 7 && Rails::VERSION::MINOR >= 1
      serialize :tokens, coder: DeviseTokenAuth::Concerns::TokensSerialization
    else
      serialize :tokens, DeviseTokenAuth::Concerns::TokensSerialization
    end
  end

  class_methods do
    # It's abstract replacement .find_by
    def dta_find_by(attrs = {})
      find_by(attrs)
    end
  end
end
