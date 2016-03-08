module DeviseTokenAuth::Concerns::JsonApiHelpers
  extend ActiveSupport::Concern

  included do
    before_action :set_json_api_headers
  end

  protected

  # Sets the JSON API media type headers on the response object.
  def set_json_api_headers
    if configured_format == :json_api && response.present?
      response.headers['HTTP_ACCEPT']   = 'application/vnd.api+json'
      response.headers['CONTENT_TYPE']  = 'application/vnd.api+json'
    end
  end

  # Raises an ArgumentError when the `format` argument is unknown.
  def raise_unknown_format_argument_error
    raise ArgumentError, 'Unknown format argument specified', caller
  end

  # Returns the response rendering format specified in the config.
  def configured_format
    DeviseTokenAuth.response_format
  end

end
