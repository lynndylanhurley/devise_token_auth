module DeviseTokenAuth::Concerns::JsonApiHelpers
  extend ActiveSupport::Concern

  included do
    before_action :set_json_api_headers
  end

  protected

  def render_json_api_data(data_hash, status)
    self.set_json_api_headers
    render json: {
      data: data_hash
    }, status: status
  end

  def render_json_api_errors(errors_array, status)
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
    DeviseTokenAuth.response_format
  end

end
