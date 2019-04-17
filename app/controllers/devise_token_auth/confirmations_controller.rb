# frozen_string_literal: true

module DeviseTokenAuth
  class ConfirmationsController < DeviseTokenAuth::ApplicationController
    def create
      return head :bad_request if params[:email].blank?

      @resource = resource_class.dta_find_by(uid: params[:email].downcase, provider: provider)

      return head :not_found unless @resource

      @resource.send_confirmation_instructions({
        redirect_url: redirect_url,
        client_config: params[:config_name]
      })

      head :ok
    end

    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @resource.errors.empty?
        yield @resource if block_given?

        redirect_header_options = { account_confirmation_success: true }

        client_id, token = @resource.create_token

        sign_in(:user, @resource, store: false, bypass: false)
        @resource.save!

        redirect_headers = build_redirect_headers(token,
                                                  client_id,
                                                  redirect_header_options)

        redirect_to(@resource.build_auth_url(redirect_url, redirect_headers))
      else
        raise ActionController::RoutingError, 'Not Found'
      end
    end

    private

    # give redirect value from params priority or fall back to default value if provided
    def redirect_url
      params.fetch(
        :redirect_url,
        DeviseTokenAuth.default_confirm_success_url
      )
    end

  end
end
