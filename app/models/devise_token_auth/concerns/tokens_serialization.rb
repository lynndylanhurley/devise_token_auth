module DeviseTokenAuth::Concerns::TokensSerialization
  # Serialization hash to json
  def self.dump(object)
    object.each_value(&:compact!) unless object.nil?
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
