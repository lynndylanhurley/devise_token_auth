module DeviseTokenAuth
  class ApplicationController < DeviseController
    include DeviseTokenAuth::Concerns::SetUserByToken

    def resource_data
      response_data = @resource.as_json
      if is_json_api
        response_data['type'] = @resource.class.name.parameterize
      end
      response_data
    end

    def resource_errors
      return @resource.errors.to_hash.merge(full_messages: @resource.errors.full_messages)
    end

    protected

    def params_for_resource(resource)
      devise_parameter_sanitizer.instance_values['permitted'][resource]
    end

    def resource_class(m=nil)
      if m
        mapping = Devise.mappings[m]
      else
        mapping = Devise.mappings[resource_name] || Devise.mappings.values.first
      end

      mapping.to
    end

    def is_json_api
      return false unless defined?(ActiveModel::Serializer)
      return ActiveModel::Serializer.config.adapter == :json_api
    end

  end
end
