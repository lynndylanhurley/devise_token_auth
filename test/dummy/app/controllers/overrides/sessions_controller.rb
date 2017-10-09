module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    OVERRIDE_PROOF = "(^^,)"

    def create
      @resource = resource_class.find_by(email: resource_params[:email])

      if @resource and valid_params?(:email, resource_params[:email]) and @resource.valid_password?(resource_params[:password]) and @resource.confirmed?
        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + @resource.token_lifespan).to_i
        }
        @resource.save

        render json: {
          data: @resource.as_json(except: [
            :tokens, :created_at, :updated_at
          ]),
          override_proof: OVERRIDE_PROOF
        }

      elsif @resource and not @resource.confirmed?
        render json: {
          success: false,
          errors: [
            "A confirmation email was sent to your account at #{@resource.email}. "+
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
