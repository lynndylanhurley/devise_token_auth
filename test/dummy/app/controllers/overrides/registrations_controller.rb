module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    OVERRIDE_PROOF = "(^^,)"

    def update
      if @resource
        if @resource.update_attributes(account_update_params)
          render json: {
            status: 'success',
            data:   @resource.as_json,
            override_proof: OVERRIDE_PROOF
          }
        else
          render json: {
            status: 'error',
            errors: @resource.errors
          }, status: 422
        end
      else
        render json: {
          status: 'error',
          errors: {
            full_messages: [I18n.t('devise_token_auth.registrations.user_not_found')]
          }
        }, status: 404
      end
    end
  end
end
