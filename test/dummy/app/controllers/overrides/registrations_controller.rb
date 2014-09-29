module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    OVERRIDE_PROOF = "(^^,)"

    def update
      if @user
        if @user.update_attributes(account_update_params)
          render json: {
            status: 'success',
            data:   @user.as_json,
            override_proof: OVERRIDE_PROOF
          }
        else
          render json: {
            status: 'error',
            errors: @user.errors
          }, status: 403
        end
      else
        render json: {
          status: 'error',
          errors: ["User not found."]
        }, status: 404
      end
    end
  end
end
