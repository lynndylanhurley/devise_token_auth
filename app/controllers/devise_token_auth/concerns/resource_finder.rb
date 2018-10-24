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

  def find_resource(field, value)
    @resource = if resource_class.try(:connection_config).try(:[], :adapter).try(:include?, 'mysql')
                  # fix for mysql default case insensitivity
                  resource_class.where("BINARY #{field} = ? AND provider= ?", value, provider).first
                else
                  resource_class.dta_find_by(field => value, 'provider' => provider)
                end
  end

  def resource_class(m = nil)
    mapping = if m
                Devise.mappings[m]
              else
                Devise.mappings[resource_name] || Devise.mappings.values.first
              end

    mapping.to
  end

  def provider
    'email'
  end
end
