module DeviseTokenAuth
  class ConfirmationsController < Devise::ConfirmationsController
    include Devise::Controllers::Helpers

    def show
      @user = User.confirm_by_token(params[:confirmation_token])
      if @user
        # create client id
        client_id  = SecureRandom.urlsafe_base64(nil, false)

        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        @user.tokens[client_id] = {
          token:  token_hash,
          expiry: Time.now + 2.weeks
        }
        @user.save!

        redirect_to generate_url(@user.confirm_success_url, {
          token:     token,
          client_id: client_id,
          uid:       @user.uid
        })
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def generate_url(url, params = {})
      uri = URI(url)
      uri.query = params.to_query
      uri.to_s
    end
  end
end
