# frozen_string_literal: true

module DeviseTokenAuth
  class ConfirmationsController < DeviseTokenAuth::ApplicationController
    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @resource.errors.empty?
        yield @resource if block_given?

        redirect_header_options = { account_confirmation_success: true }

        # give redirect value from params priority or fall back to default value if provided
        redirect_url = params[:redirect_url] || DeviseTokenAuth.default_confirm_success_url

        if signed_in?(resource_name)
          client_id, token = signed_in_resource.create_token

          redirect_headers = build_redirect_headers(token,
                                                    client_id,
                                                    redirect_header_options)

          redirect_to_link = signed_in_resource.build_auth_url(redirect_url, redirect_headers)
        else
          redirect_to_link = DeviseTokenAuth::Url.generate(redirect_url, redirect_header_options)
       end

        redirect_to(redirect_to_link)
      else
        raise ActionController::RoutingError, 'Not Found'
      end
    end
  end
end
