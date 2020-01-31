module DeviseTokenAuth::Concerns::TokensSerialization
  # Serialization hash to json
  def self.dump(object)
    object.each_value do |value|
      if (updated_at_key = ['updated_at', :updated_at].find(&value.method(:[])))
        if value[updated_at_key].respond_to?(:iso8601)
          value[updated_at_key] = value[updated_at_key].iso8601
        end
      end
    end unless object.nil?
    JSON.generate(object)
  end

  # Deserialization json to hash
  def self.load(json)
    case json
    when String
      JSON.parse(json)
    when NilClass
      {}
    else
      json
    end
  end
end
