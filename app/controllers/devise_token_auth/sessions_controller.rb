# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
module DeviseTokenAuth
  class SessionsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, :only => [:destroy]

    def create
      # honor devise configuration for case_insensitive_keys
      if resource_class.case_insensitive_keys.include?(:email)
        email = resource_params[:email].downcase
      else
        email = resource_params[:email]
      end

      q = "uid='#{email}' AND provider='email'"

      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
        q = "BINARY uid='#{email}' AND provider='email'"
      end

      @resource = resource_class.where(q).first

      if @resource and valid_params? and @resource.valid_password?(resource_params[:password]) and @resource.confirmed?
        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }
        @resource.save

        sign_in(:user, @resource, store: false, bypass: false)

        render json: {
          data: @resource.as_json(except: [
            :tokens, :created_at, :updated_at
          ])
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

    def destroy
      # remove auth instance variables so that after_filter does not run
      user = remove_instance_variable(:@resource) if @resource
      client_id = remove_instance_variable(:@client_id) if @client_id
      remove_instance_variable(:@token) if @token

      if user and client_id and user.tokens[client_id]
        user.tokens.delete(client_id)
        user.save!

        render json: {
          success:true
        }, status: 200

      else
        render json: {
          errors: ["User was not found or was not logged in."]
        }, status: 404
      end
    end

    def valid_params?
      resource_params[:password] && resource_params[:email]
    end

    def resource_params
      params.permit(devise_parameter_sanitizer.for(:sign_in))
    end
  end
end
