module DeviseTokenAuth
  class ConfirmationsController < DeviseTokenAuth::ApplicationController
    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @resource && @resource.id
        # create client id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + @resource.token_lifespan).to_i

        if @resource.sign_in_count > 0
          expiry = (Time.now + 1.second).to_i
        end

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        sign_in(@resource)
        @resource.save!

        yield @resource if block_given?

        redirect_header_options = {account_confirmation_success: true}
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
