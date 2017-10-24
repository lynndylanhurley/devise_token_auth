module Overrides
  class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @resource and @resource.id
        # create client id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + @resource.token_lifespan).to_i

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        @resource.save!

        redirect_to(@resource.build_auth_url(params[:redirect_url], {
          "access-token":               token,
          account_confirmation_success: true,
          client:                       client_id,
          client_id:                    client_id,
          config:                       params[:config],
          override_proof:               "(^^,)",
          token:                        token
        }))
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
