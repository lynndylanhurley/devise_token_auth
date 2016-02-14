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

    def set_resource(default_identification)
      @resource = nil
      return unless default_identification.present?

      resource_list = [[resource_class.name, default_identification]]
      resource_list.map!{ |tmp_array| tmp_array.map(&:to_s) }

      resource_class_name = resource_class.name.parameterize.to_sym
      resource_list.each do |(class_name, field_name)|
        current_class = class_name.classify.constantize

        field_key = ( field_name == 'uid' ) ? :email : field_name.to_sym
        field_value = resource_params[field_name] || resource_params[:email]
        field_value = field_value.downcase \
          if resource_class.case_insensitive_keys.include?(field_key)

        q = current_class
        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
          q = q.where("BINARY #{field_name} = ?", field_value)
        else
          q = q.where(field_name => field_value)
        end

        if current_class == resource_class
          @resource = q.find_by(provider: 'email')
        else
          q = q.joins(resource_class_name)
          current_resource = q.find_by("#{resource_class.table_name}.provider" => 'email')
          next unless current_resource.present?
          @resource = current_resource.public_send(resource_class_name)
        end

        break if @resource.present?
      end
    end

    def is_json_api
      return false unless defined?(ActiveModel::Serializer)
      return ActiveModel::Serializer.config.adapter == :json_api
    end

  end
end
