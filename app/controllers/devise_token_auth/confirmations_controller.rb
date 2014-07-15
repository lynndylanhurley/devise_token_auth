module DeviseTokenAuth
  class ConfirmationsController < Devise::ConfirmationsController
    include Devise::Controllers::Helpers

    def show
      @user = DeviseTokenAuth.user_class.confirm_by_token(params[:confirmation_token])

      if @user and @user.id
        # create client id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        @user.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        @user.save!

        redirect_to(@user.build_auth_url(@user.confirm_success_url, {
          token:                        token,
          client_id:                    client_id,
          account_confirmation_success: true
        }))
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
