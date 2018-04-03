## Initializer settings

The following settings are available for configuration in `config/initializers/devise_token_auth.rb`:

| Name | Default | Description|
|---|---|---|
| **`change_headers_on_each_request`** | `true` | By default the access-token header will change after each request. The client is responsible for keeping track of the changing tokens. Both [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) and [jToker](https://github.com/lynndylanhurley/j-toker) do this out of the box. While this implementation is more secure, it can be difficult to manage. Set this to false to prevent the `access-token` header from changing after each request. [Read more](#about-token-management). |
| **`token_lifespan`** | `2.weeks` | Set the length of your tokens' lifespans. Users will need to re-authenticate after this duration of time has passed since their last login. |
| **`batch_request_buffer_throttle`** | `5.seconds` | Sometimes it's necessary to make several requests to the API at the same time. In this case, each request in the batch will need to share the same auth token. This setting determines how far apart the requests can be while still using the same auth token. [Read more](#about-batch-requests). |
| **`omniauth_prefix`** | `"/omniauth"` | This route will be the prefix for all oauth2 redirect callbacks. For example, using the default '/omniauth' setting, the github oauth2 provider will redirect successful authentications to '/omniauth/github/callback'. [Read more](#omniauth-provider-settings). |
| **`default_confirm_success_url`** | `nil` | By default this value is expected to be sent by the client so that the API knows where to redirect users after successful email confirmation. If this param is set, the API will redirect to this value when no value is provided by the client. |
| **`default_password_reset_url`** | `nil` | By default this value is expected to be sent by the client so that the API knows where to redirect users after successful password resets. If this param is set, the API will redirect to this value when no value is provided by the client. |
| **`redirect_whitelist`** | `nil` | As an added security measure, you can limit the URLs to which the API will redirect after email token validation (password reset, email confirmation, etc.). This value should be an array containing matches to the client URLs to be visited after validation. Wildcards are supported. |
| **`enable_standard_devise_support`** | `false` | By default, only Bearer Token authentication is implemented out of the box. If, however, you wish to integrate with legacy Devise authentication, you can do so by enabling this flag. NOTE: This feature is highly experimental! |
| **`remove_tokens_after_password_reset`** | `false` | By default, old tokens are not invalidated when password is changed. Enable this option if you want to make passwords updates to logout other devices. |
| **`default_callbacks`** | `true` | By default User model will include the `DeviseTokenAuth::Concerns::UserOmniauthCallbacks` concern, which has `email`, `uid` validations & `uid` synchronization callbacks. |
| **`bypass_sign_in`** | `true` | By default DeviseTokenAuth will not check user's `#active_for_authentication?` which includes confirmation check on each call (it will do it only on sign in). If you want it to be validated on each request (for example, to be able to deactivate logged in users on the fly), set it to false. |


Additionally, you can configure other aspects of devise by manually creating the traditional devise.rb file at `config/initializers/devise.rb`. Here are some examples of what you can do in this file:

~~~ruby
Devise.setup do |config|
  # The e-mail address that mail will appear to be sent from
  # If absent, mail is sent from "please-change-me-at-config-initializers-devise@example.com"
  config.mailer_sender = "support@myapp.com"

  # If using rails-api, you may want to tell devise to not use ActionDispatch::Flash
  # middleware b/c rails-api does not include it.
  # See: https://stackoverflow.com/q/19600905/806956
  config.navigational_formats = [:json]
end
~~~
