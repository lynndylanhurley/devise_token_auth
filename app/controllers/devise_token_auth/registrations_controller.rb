module DeviseTokenAuth
  class RegistrationsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, :only => [:destroy, :update]
    skip_after_filter :update_auth_header, :only => [:create, :destroy]

    respond_to :json

    def create
      @resource            = resource_class.new(sign_up_params)
      @resource.provider   = "email"

      # honor devise configuration for case_insensitive_keys
      if resource_class.case_insensitive_keys.include?(:email)
        @resource.email = sign_up_params[:email].downcase
      else
        @resource.email = sign_up_params[:email]
      end

      # success redirect url is required
      unless params[:confirm_success_url]
        @render =  Hashie::Mash.new({
          status: 'error',
          data: @resource,
          errors: ['Missing `confirm_success_url` param.']
        })

        return render 'devise_token_auth/registrations/missing_confirm_success_url'
      end

      # override email confirmation, must be sent manually from ctrl
      resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)
      if @resource.save

        unless @resource.confirmed?
          # user will require email authentication
          @resource.send_confirmation_instructions({
            client_config: params[:config_name],
            redirect_url: params[:confirm_success_url]
          })

        else
          # email auth has been bypassed, authenticate user
          @client_id = SecureRandom.urlsafe_base64(nil, false)
          @token     = SecureRandom.urlsafe_base64(nil, false)

          @resource.tokens[@client_id] = {
            token: BCrypt::Password.create(@token),
            expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
          }

          @resource.save!

          update_auth_header
        end

        @render = Hashie::Mash.new({
          status: 'success',
          data:   @resource.as_json
        })

        render 'devise_token_auth/registrations/create_success'
      else
        clean_up_passwords @resource

        @render = Hashie::Mash.new({
           status: 'error',
           data:   @resource,
           errors: @resource.errors.to_hash.merge(full_messages: @resource.errors.full_messages)
        })

        render 'devise_token_auth/registrations/create_errors', status: 403
      end

    end

    def update
      if @resource

        if @resource.update_attributes(account_update_params)
          @render = Hashie::Mash.new({
            status: 'success',
            data:   @resource.as_json
          })

          render 'devise_token_auth/registrations/update_success'
        else
          @render = Hashie::Mash.new({
            status: 'error',
            errors: @resource.errors
          })

          render 'devise_token_auth/registrations/update_errors', status: 403
        end
      else
        @render = Hashie::Mash.new({
          status: 'error',
          errors: ['User not found.']
        })

        render 'devise_token_auth/registrations/update_errors', status: 404
      end
    end

    def destroy
      if @resource
        @resource.destroy

        @render = Hashie::Mash.new({
          status: 'success',
          message: "Account with uid #{@resource.uid} has been destroyed."
        })

        render 'devise_token_auth/registrations/destroy_success'
      else
        @render = Hashie::Mash.new({
          status: 'error',
          errors: ['Unable to locate account for destruction.']
        })

        render 'devise_token_auth/registrations/destroy_errors', status: 404
      end
    end

    def sign_up_params
      params.permit(devise_parameter_sanitizer.for(:sign_up))
    end

    def account_update_params
      params.permit(devise_parameter_sanitizer.for(:account_update))
    end
  end
end
