module DeviseTokenAuth
  class ConfirmationsController < Devise::ConfirmationsController
    include Devise::Controllers::Helpers

    def show
      @user = User.confirm_by_token(params[:confirmation_token])

      if @user and @user.id
        # create client id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = Time.now + DeviseTokenAuth.token_lifespan

        @user.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        @user.save!

        redirect_to(@user.build_auth_url(@user.confirm_success_url, {
          token:     token,
          client_id: client_id
        }))
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
