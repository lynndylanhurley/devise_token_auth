module DeviseTokenAuth::Concerns::JsonApiHelpers
  extend ActiveSupport::Concern

  included do
    before_action :set_json_api_headers
  end

  protected

  def render_json_api_data(data_hash, status = 200)
    self.set_json_api_headers
    render json: {
      data: data_hash
    }, status: status
  end

  def render_json_api_errors(errors_array, status = 400)
    self.set_json_api_headers
    render json: {
      errors: errors_array
    }, status: status
  end

  # Sets the JSON API media type headers on the response object.
  def set_json_api_headers
    if response_format == :json_api && response.present?
      response.headers['CONTENT_TYPE']  = 'application/vnd.api+json'
    end
  end

  # Raises an ArgumentError when the `format` argument is unknown.
  def raise_unknown_format_argument_error
    raise ArgumentError, 'Unknown format argument specified', caller
  end

  # Returns the response rendering format specified in the config.
  def response_format
    # TODO: automatically detect response format by looking at request HTTP ACCEPT
    DeviseTokenAuth.response_format
  end

end


class ValidationErrors < RuntimeError
  attr_reader :error_messages

  def initialize(resource)
    @error_messages = resource.model_error_messages
  end

  def json_api_errors
    error_messages.map do |attribute, messages|
      json_api_error(attribute, messages.join(', '))
    end
  end

  private

  def json_api_error(attribute, message)
    {
      source: { parameter: attribute.to_s },
      detail: message
    }
  end

end
