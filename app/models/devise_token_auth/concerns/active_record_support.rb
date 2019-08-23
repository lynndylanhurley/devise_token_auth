require_relative 'tokens_serialization'

module DeviseTokenAuth::Concerns::ActiveRecordSupport
  extend ActiveSupport::Concern

  included do
    serialize :tokens, DeviseTokenAuth::Concerns::TokensSerialization
  end

  class_methods do
    # It's abstract replacement .find_by
    def dta_find_by(attrs = {})
      find_by(attrs)
    end
  end
end
