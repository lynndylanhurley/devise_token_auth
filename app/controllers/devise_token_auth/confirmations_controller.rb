module DeviseTokenAuth
  class ConfirmationsController < DeviseTokenAuth::ApplicationController
    def show
      @resource = resource_class.confirm_by_token(data_attributes[:confirmation_token])

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

        yield if block_given?

        redirect_to(@resource.build_auth_url(data_attributes[:redirect_url], {
          token:                        token,
          client_id:                    client_id,
          account_confirmation_success: true,
          config:                       data_attributes[:config]
        }))
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
