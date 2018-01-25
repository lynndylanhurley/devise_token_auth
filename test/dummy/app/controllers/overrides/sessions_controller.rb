module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    OVERRIDE_PROOF = "(^^,)"

    def create
      @resource = resource_class.find_by(email: resource_params[:email])

      if @resource and valid_params?(:email, resource_params[:email]) and @resource.valid_password?(resource_params[:password]) and @resource.confirmed?
        @client_id, @token = @resource.create_token
        @resource.save

        render json: {
          data: @resource.as_json(except: [
            :tokens, :created_at, :updated_at
          ]),
          override_proof: OVERRIDE_PROOF
        }

      elsif @resource and not @resource.confirmed?
        render json: {
          success: false,
          errors: {
            full_messages: [I18n.t('devise_token_auth.sessions.not_confirmed', @resource.email)]
          } 
        }, status: 401

      else
        render json: {
          errors: {
            full_messages: [I18n.t('devise_token_auth.sessions.bad_credentials')]
          }
        }, status: 401
      end
    end
  end
end
