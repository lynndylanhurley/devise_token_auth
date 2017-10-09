module DeviseTokenAuth
  class UnlocksController < DeviseTokenAuth::ApplicationController
    skip_after_action :update_auth_header, :only => [:create, :show]

    # this action is responsible for generating unlock tokens and
    # sending emails
    def create
      unless resource_params[:email]
        return render_create_error_missing_email
      end

      # honor devise configuration for case_insensitive_keys
      if resource_class.case_insensitive_keys.include?(:email)
        @email = resource_params[:email].downcase
      else
        @email = resource_params[:email]
      end

      q = "uid = ? AND provider='email'"

      # fix for mysql default case insensitivity
      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
        q = "BINARY uid = ? AND provider='email'"
      end

      @resource = resource_class.where(q, @email).first

      @errors = nil
      @error_status = 400

      if @resource
        yield @resource if block_given?

        @resource.send_unlock_instructions({
          email: @email,
          provider: 'email',
          client_config: params[:config_name]
        })

        if @resource.errors.empty?
          return render_create_success
        else
          @errors = @resource.errors
        end
      else
        @errors = [I18n.t("devise_token_auth.unlocks.user_not_found", email: @email)]
        @error_status = 404
      end

      if @errors
        return render_create_error
      end
    end

    def show
      @resource = resource_class.unlock_access_by_token(params[:unlock_token])

      if @resource && @resource.id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        @resource.save!
        yield @resource if block_given?

        redirect_to(@resource.build_auth_url(after_unlock_path_for(@resource), {
          token:          token,
          client_id:      client_id,
          unlock:         true,
          config:         params[:config]
        }))
      else
        render_show_error
      end
    end

    private
    def after_unlock_path_for(resource)
      #TODO: This should probably be a configuration option at the very least.
      # root_url
      '/'
    end

    def render_create_error_missing_email
      render json: {
        success: false,
        errors: [I18n.t("devise_token_auth.unlocks.missing_email")]
      }, status: 401
    end

    def render_create_success
      render json: {
        success: true,
        message: I18n.t("devise_token_auth.unlocks.sended", email: @email)
      }
    end

    def render_create_error
      render json: {
        success: false,
        errors: @errors,
      }, status: @error_status
    end

    def render_show_error
      raise ActionController::RoutingError.new('Not Found')
    end

    def resource_params
      params.permit(:email, :unlock_token, :config)
    end
  end
end