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

  def meta_params
    case request_format
    when :custom    # custom JSON request format
      params
    when :json_api  # JSON API specification compliant request format
      json_api_meta_params
    else
      raise_unknown_format_argument_error
    end
  end

  def data_attributes
    case request_format
    when :custom    # custom JSON request format
      params
    when :json_api  # JSON API specification compliant request format
      json_api_data_attributes
    else
      raise_unknown_format_argument_error
    end
  end

  def json_api_meta_params
    ActionController::Parameters.new(params.slice(:meta))
  end

  def json_api_data_params
    ActionController::Parameters.new(params.slice(:data))
  end

  def json_api_data_attributes
    ActionController::Parameters.new(self.json_api_data_params.slice(:attributes))
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

  # Returns the request format specified via config and request.
  def request_format
    format_for_http_header :content_type
  end

  # Returns the response rendering format specified via config and request.
  def response_format
    format_for_http_header :accept
  end

  private

  def format_for_http_header(header_key)
    accept = request.env["HTTP_#{header_key.to_s.upcase}"] if request.present?
    if DeviseTokenAuth.json_api_enabled && accept.present? && accept.include?('application/vnd.api+json')
      :json_api
    else
      :custom
    end
  end

end
