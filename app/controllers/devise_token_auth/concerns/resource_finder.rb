module DeviseTokenAuth::Concerns::ResourceFinder
  extend ActiveSupport::Concern
  include DeviseTokenAuth::Controllers::Helpers

  def get_case_insensitive_field_from_resource_params(field)
    # honor Devise configuration for case_insensitive keys
    q_value = resource_params[field.to_sym]

    if resource_class.case_insensitive_keys.include?(field.to_sym)
      q_value.downcase!
    end
    q_value
  end

  def find_resource

    fields = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys)

    conditions = []
    values = {}
    fields.each do |f|
      q = " #{f.to_s} = :#{f.to_s} "
      # fix for mysql default case insensitivity
      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
        q = "BINARY " + q
      end
      conditions.push(q)
      values[f.to_sym] = get_case_insensitive_field_from_resource_params(f)
    end

    conditions.push(' provider = :provider')
    values[:provider] = provider.to_s

    @resource = resource_class.where([conditions.join(" AND "), values]).first
  end

  def resource_class(m=nil)
    if m
      mapping = Devise.mappings[m]
    else
      mapping = Devise.mappings[resource_name] || Devise.mappings.values.first
    end

    mapping.to
  end

  def provider
    'email'
  end
end
