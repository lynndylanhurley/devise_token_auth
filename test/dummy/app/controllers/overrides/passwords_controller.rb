module Overrides
  class PasswordsController < DeviseTokenAuth::PasswordsController
    OVERRIDE_PROOF = "(^^,)"

    # this is where users arrive after visiting the email confirmation link
    def edit
      @user = resource_class.reset_password_by_token({
        reset_password_token: resource_params[:reset_password_token]
      })

      if @user and @user.id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        @user.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        # ensure that user is confirmed
        @user.skip_confirmation! unless @user.confirmed_at

        @user.save!

        redirect_to(@user.build_auth_url(params[:redirect_url], {
          token:          token,
          client_id:      client_id,
          reset_password: true,
          config:         params[:config],
          override_proof: OVERRIDE_PROOF
        }))
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
