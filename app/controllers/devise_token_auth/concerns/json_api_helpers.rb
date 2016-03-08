module DeviseTokenAuth::Concerns::JsonApiHelpers

  # Raises an ArgumentError when the `format` argument is unknown.
  def raise_unknown_format_argument_error
    raise ArgumentError, 'Unknown format argument specified', caller
  end

end
