# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
module DeviseTokenAuth
  class SessionsController < DeviseTokenAuth::ApplicationController
    before_action :set_user_by_token, :only => [:destroy]
    after_action :reset_session, :only => [:destroy]

    def new
      render_new_error
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

        q = "#{field.to_s} = ? AND provider='email'"

        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
          q = "BINARY " + q
        end

        @resource = resource_class.where(q, q_value).first
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

        render_create_success
      elsif @resource and not (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
        render_create_error_not_confirmed
      else
        render_create_error_bad_credentials
      end
    end

    def destroy
      # remove auth instance variables so that after_action does not run
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

    def render_new_error
      case response_format
      when :custom    # custom JSON response format
        render json: {
          errors: [I18n.t("devise_token_auth.sessions.not_supported")]
        }, status: 405
      when :json_api  # JSON API specification compliant response format
        render_json_api_errors [{
          detail: I18n.t("devise_token_auth.sessions.not_supported")
        }], 405
      else
        raise_unknown_format_argument_error
      end
    end

    def render_create_success
      case response_format
      when :custom    # custom JSON response format
        render json: {
          data: resource_data(resource_json: @resource.token_validation_response)
        }
      when :json_api  # JSON API specification compliant response format
        render_json_api_meta({
          data: resource_data(resource_json: @resource.token_validation_response)
        })
      else
        raise_unknown_format_argument_error
      end
    end

    def render_create_error_not_confirmed
      case response_format
      when :custom    # custom JSON response format
        render json: {
          success: false,
          errors:  [I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email)]
        }, status: 401
      when :json_api  # JSON API specification compliant response format
        render_json_api_errors [{
          detail: I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email)
        }], 401
      else
        raise_unknown_format_argument_error
      end
    end

    def render_create_error_bad_credentials
      case response_format
      when :custom    # custom JSON response format
        render json: {
          errors: [I18n.t("devise_token_auth.sessions.bad_credentials")]
        }, status: 401
      when :json_api  # JSON API specification compliant response format
        render_json_api_errors [{
          detail: I18n.t("devise_token_auth.sessions.bad_credentials")
        }], 401
      else
        raise_unknown_format_argument_error
      end
    end

    def render_destroy_success
      case response_format
      when :custom    # custom JSON response format
        render json: {
          success: true
        }, status: 200
      when :json_api  # JSON API specification compliant response format
        render_json_api_meta({
          success: true
        })
      else
        raise_unknown_format_argument_error
      end
    end

    def render_destroy_error
      case response_format
      when :custom    # custom JSON response format
        render json: {
          errors: [I18n.t("devise_token_auth.sessions.user_not_found")]
        }, status: 404
      when :json_api  # JSON API specification compliant response format
        render_json_api_errors [{
          source: { parameter: 'uid' },
          detail: I18n.t("devise_token_auth.sessions.user_not_found")
        }], 404
      else
        raise_unknown_format_argument_error
      end
    end


    private

    def resource_params
      params.permit(*params_for_resource(:sign_in))
    end

  end
end
