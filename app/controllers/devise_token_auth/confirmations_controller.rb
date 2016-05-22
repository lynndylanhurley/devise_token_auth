module DeviseTokenAuth
  class ConfirmationsController < DeviseTokenAuth::ApplicationController
    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @resource and @resource.id
        # create client id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        @resource.save!

        yield @resource if block_given?

        redirect_to(@resource.build_auth_url(params[:redirect_url], {
          token:                        token,
          client_id:                    client_id,
          account_confirmation_success: true,
          config:                       params[:config]
        }))
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
