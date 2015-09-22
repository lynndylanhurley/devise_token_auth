# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
module DeviseTokenAuth
  class SessionsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, :only => [:destroy]
    before_filter :set_auth_hash!, :except => [:destroy] # mutually exclusive since set_user_by_token calls this.

    after_action :reset_session, :only => [:destroy]

    def new
      render_sessions_controller_new_error
    end

    def create
      # Check
      field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

      @resource = nil
      if field
        q_value = resource_params[field]

        if resource_class.case_insensitive_keys.include?(field)
          q_value.downcase!
        end

        @auth_hash.merge!(field.to_sym => q_value, provider: 'email')
        @resource = resource_class.find_for_authentication(@auth_hash)
      end

      if @resource and valid_params?(field, q_value) and @resource.valid_password?(resource_params[:password]) and (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }
        @resource.save

        sign_in(:user, @resource, store: false, bypass: false)

        yield if block_given?

        render_sessions_controller_create_success
      elsif @resource and not (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
        render_sessions_controller_create_error_not_confirmed
      else
        render_sessions_controller_create_error_bad_credentials
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

        yield if block_given?

        render_sessions_controller_destroy_success
      else
        render_sessions_controller_destroy_error
      end
    end

    protected

    def valid_params?(key, val)
      resource_params[:password] && key && val
    end

    def get_auth_params
      auth_key = nil
      auth_val = nil

      # iterate thru allowed auth keys, use first found
      resource_class.authentication_keys.each do |k|
        if resource_params[k]
          auth_val = resource_params[k]
          auth_key = k
          break
        end
      end

      # honor devise configuration for case_insensitive_keys
      if resource_class.case_insensitive_keys.include?(auth_key)
        auth_val.downcase!
      end

      return {
        key: auth_key,
        val: auth_val
      }
    end

    def render_sessions_controller_new_error
      render json: {
        errors: [ I18n.t("devise_token_auth.sessions.not_supported")]
      }, status: 405
    end

    def render_sessions_controller_create_success
      render json: {
        data: @resource.token_validation_response
      }
    end

    def render_sessions_controller_create_error_not_confirmed
      render json: {
        success: false,
        errors: [ I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email) ]
      }, status: 401
    end

    def render_sessions_controller_create_error_bad_credentials
      render json: {
        errors: [I18n.t("devise_token_auth.sessions.bad_credentials")]
      }, status: 401
    end

    def render_sessions_controller_destroy_success
      render json: {
        success:true
      }, status: 200
    end

    def render_sessions_controller_destroy_error
      render json: {
        errors: [I18n.t("devise_token_auth.sessions.user_not_found")]
      }, status: 404
    end


    private

    def resource_params
      params.permit(devise_parameter_sanitizer.for(:sign_in))
    end

  end
end
