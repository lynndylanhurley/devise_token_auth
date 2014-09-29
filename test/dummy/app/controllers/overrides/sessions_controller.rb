module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    OVERRIDE_PROOF = "(^^,)"

    def create
      @user = resource_class.find_by_email(resource_params[:email])

      if @user and valid_params? and @user.valid_password?(resource_params[:password]) and @user.confirmed?
        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @user.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }
        @user.save

        render json: {
          data: @user.as_json(except: [
            :tokens, :created_at, :updated_at
          ]),
          override_proof: OVERRIDE_PROOF
        }

      elsif @user and not @user.confirmed?
        render json: {
          success: false,
          errors: [
            "A confirmation email was sent to your account at #{@user.email}. "+
            "You must follow the instructions in the email before your account "+
            "can be activated"
          ]
        }, status: 401

      else
        render json: {
          errors: ["Invalid login credentials. Please try again."]
        }, status: 401
      end
    end
  end
end
