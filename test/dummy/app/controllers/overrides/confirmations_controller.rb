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

        redirect_header_options = {
          account_confirmation_success: true,
          config: params[:config],
          override_proof: "(^^,)"
        }
        redirect_headers = build_redirect_headers(token,
                                                  client_id,
                                                  redirect_header_options)

        redirect_to(@resource.build_auth_url(params[:redirect_url],
                                             redirect_headers))
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
