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

        render json: {
          account_confirmation_success: true,
          token:                        token,
          client_id:                    client_id,
          uid:                          @resource.uid,
          config:                       params[:config],
          expiry:                       expiry
        }
      else
        render json: {
          account_confirmation_success: false
        }
      end
    end
  end
end
