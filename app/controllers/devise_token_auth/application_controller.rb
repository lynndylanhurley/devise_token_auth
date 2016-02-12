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

    def set_resource(default_identification, value)
      @resource = nil
      return unless default_identification.present? && value.present?

      resource_list = [[resource_class.name, default_identification]]
      backup_identification = resource_params[:backup_field_name]
      if backup_identification.present?
        backup_class = resource_params[:backup_field_class]
        backup_class ||= resource_class.name
        resource_list << [backup_class, backup_identification]
      end
      resource_list.map!{ |tmp_array| tmp_array.map(&:to_s) }

      resource_class_name = resource_class.name.parameterize.to_sym
      resource_list.each do |(class_name, field_name)|
        current_class = class_name.classify.constantize

        q = current_class
        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
          q = q.where("BINARY #{field_name} = ?", value)
        else
          q = q.where(field_name => value)
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
  end
end
