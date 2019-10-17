module DeviseTokenAuth::Concerns::ConfirmableSupport
  extend ActiveSupport::Concern

  included do
    if Devise.rails51? && self.method_defined?(:email_in_database)
      def postpone_email_change?
        postpone = self.class.reconfirmable &&
          will_change_email? &&
          !@bypass_confirmation_postpone &&
          self.email.present? &&
          (!@skip_reconfirmation_in_callback || !self.email_in_database.nil?)
        @bypass_confirmation_postpone = false
        postpone
      end
    else
      def postpone_email_change?
        postpone = self.class.reconfirmable &&
          will_change_email? &&
          !@bypass_confirmation_postpone &&
          self.email.present? &&
          (!@skip_reconfirmation_in_callback || !self.email_was.nil?)
        @bypass_confirmation_postpone = false
        postpone
      end
    end
  end

  protected

  def will_change_email?
    if Devise.rails51? && self.respond_to?(:email_in_database)
      email_in_database != email
    else
      email_was != email
    end
  end
end
