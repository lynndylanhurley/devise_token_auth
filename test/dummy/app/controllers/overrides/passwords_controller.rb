module Overrides
  class PasswordsController < DeviseTokenAuth::PasswordsController
    OVERRIDE_PROOF = "(^^,)"

    # this is where users arrive after visiting the email confirmation link
    def edit
      @resource = resource_class.reset_password_by_token({
        reset_password_token: resource_params[:reset_password_token]
      })

      if @resource and @resource.id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + @resource.token_lifespan).to_i

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        # ensure that user is confirmed
        @resource.skip_confirmation! unless @resource.confirmed_at

        @resource.save!

        redirect_header_options = {
          override_proof: OVERRIDE_PROOF,
          reset_password: true
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
