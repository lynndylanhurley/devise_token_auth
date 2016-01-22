module DeviseTokenAuth
  class ApplicationController < DeviseController
    include DeviseTokenAuth::Concerns::SetUserByToken

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
  end
end
