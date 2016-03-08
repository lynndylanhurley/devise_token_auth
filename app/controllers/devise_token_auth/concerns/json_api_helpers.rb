module DeviseTokenAuth::Concerns::JsonApiHelpers

  protected

  # Raises an ArgumentError when the `format` argument is unknown.
  def raise_unknown_format_argument_error
    raise ArgumentError, 'Unknown format argument specified', caller
  end

  # Returns the response rendering format specified in the config.
  def configured_format
    DeviseTokenAuth.response_format
  end

end
