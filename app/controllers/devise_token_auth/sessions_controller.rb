# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
module DeviseTokenAuth
  class SessionsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, :only => [:destroy]
    after_action :reset_session, :only => [:destroy]

    def new
      render_new_error
    end

    def create
      field = resource_class.authentication_field_for(resource_params.keys.map(&:to_sym))

      if field
        @resource = resource_class.find_resource(resource_params[field], field)
      end

      if @resource and @resource.valid_password?(resource_params[:password]) and (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
        auth_values = @resource.create_new_auth_token(nil, resource_params[field], field)

        # These instance variables are required when updating the auth headers
        # at the end of the request, see:
        #   DeviseTokenAuth::Concerns::SetUserByToken#update_auth_header
        @token       = auth_values["access-token"]
        @client_id   = auth_values["client"]
        @provider    = "email"
        @provider_id = @resource.email

        # REVIEW: Shouldn't this be a "mapping" option, rather than a :user?
        sign_in(:user, @resource, store: false, bypass: false)

        yield if block_given?

        render_create_success
      elsif @resource and not (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
        render_create_error_not_confirmed
      else
        render_create_error_bad_credentials
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

        render_destroy_success
      else
        render_destroy_error
      end
    end

    protected

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

    def render_new_error
      render json: {
        errors: [ I18n.t("devise_token_auth.sessions.not_supported")]
      }, status: 405
    end

    def render_create_success
      render json: {
        data: @resource.token_validation_response
      }
    end

    def render_create_error_not_confirmed
      render json: {
        success: false,
        errors: [ I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email) ]
      }, status: 401
    end

    def render_create_error_bad_credentials
      render json: {
        errors: [I18n.t("devise_token_auth.sessions.bad_credentials")]
      }, status: 401
    end

    def render_destroy_success
      render json: {
        success:true
      }, status: 200
    end

    def render_destroy_error
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
