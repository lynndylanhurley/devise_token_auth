module DeviseTokenAuth::Concerns::JsonApiHelpers
  extend ActiveSupport::Concern

  included do
    before_action :set_json_api_headers
  end

  protected

  def render_json_api_data(data_hash, status = 200, meta_hash = nil)
    content_hash = { data: data_hash }
    content_hash[:meta] = meta_hash if meta_hash.present?

    self.set_json_api_headers
    render json: content_hash, status: status
  end

  def render_json_api_errors(errors_array, status = 400)
    self.set_json_api_headers
    render json: {
      errors: errors_array
    }, status: status
  end

  def render_json_api_meta(meta_hash, status = 200)
    content_hash = { meta: meta_hash }

    self.set_json_api_headers
    render json: content_hash, status: status
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
    if request.present? && request.env['HTTP_ACCEPT'].present? && request.env['HTTP_ACCEPT'].include?('application/vnd.api+json')
      :json_api
    else
      :custom
    end
  end

end
