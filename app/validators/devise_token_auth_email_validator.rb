# frozen_string_literal: true

class DeviseTokenAuthEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors.add(attribute, email_invalid_message)
    end
  end

  private

  def email_invalid_message
    # Try strictly set message:
    message = options[:message]

    if message.nil?
      # Try DeviceTokenAuth translations or fallback to ActiveModel translations
      message = I18n.t(:'errors.messages.not_email', default: :'errors.messages.invalid')
    end

    message
  end
end
