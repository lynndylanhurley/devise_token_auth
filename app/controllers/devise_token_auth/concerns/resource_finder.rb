# frozen_string_literal: true

module DeviseTokenAuth::Concerns::ResourceFinder
  extend ActiveSupport::Concern
  include DeviseTokenAuth::Controllers::Helpers

  def get_case_insensitive_field_from_resource_params(field)
    # honor Devise configuration for case_insensitive keys
    q_value = resource_params[field.to_sym]

    if resource_class.case_insensitive_keys.include?(field.to_sym)
      q_value.downcase!
    end

    if resource_class.strip_whitespace_keys.include?(field.to_sym)
      q_value.strip!
    end

    q_value
  end

  def find_resource

    fields = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys)

    conditions = []
    values = {}
    fields.each do |field|
      condition = " #{field.to_s} = :#{field.to_s} "
      # fix for mysql default case insensitivity
      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
        condition = "BINARY " + condition
      end
      conditions.push(condition)
      values[field.to_sym] = get_case_insensitive_field_from_resource_params(field)
    end

    conditions.push(' provider = :provider')
    values[:provider] = provider.to_s

    @resource = resource_class.where([conditions.join(' AND '), values]).first
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
