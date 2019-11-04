## Initializer settings

The following settings are available for configuration in `config/initializers/devise_token_auth.rb`:


| Name (default) | Description|
|---|---|
| **`change_headers_on_each_request`** (`true`) | By default the access-token header will change after each request. The client is responsible for keeping track of the changing tokens. Both [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) and [jToker](https://github.com/lynndylanhurley/j-toker) do this out of the box. While this implementation is more secure, it can be difficult to manage. Set this to false to prevent the `access-token` header from changing after each request.  |
| **`token_lifespan`** (`2.weeks`) | Set the length of your tokens' lifespans. Users will need to re-authenticate after this duration of time has passed since their last login. |
| **`token_cost`** (`10`) | Set the cost of your tokens' cost. The possible cost value is within range from 4 to 31. It is recommended to not use a value more than 10. For details see [BCrypt Cost Factors](https://github.com/codahale/bcrypt-ruby#cost-factors). |
| **`batch_request_buffer_throttle`** (`5.seconds`) | Sometimes it's necessary to make several requests to the API at the same time. In this case, each request in the batch will need to share the same auth token. This setting determines how far apart the requests can be while still using the same auth token.|
| **`omniauth_prefix`** (`"/omniauth"`) | This route will be the prefix for all oauth2 redirect callbacks. For example, using the default '/omniauth' setting, the github oauth2 provider will redirect successful authentications to '/omniauth/github/callback'. |
| **`default_confirm_success_url`** (`nil`) | By default this value is expected to be sent by the client so that the API knows where to redirect users after successful email confirmation. If this param is set, the API will redirect to this value when no value is provided by the client. |
| **`default_password_reset_url`** (`nil`) | By default this value is expected to be sent by the client so that the API knows where to redirect users after successful password resets. If this param is set, the API will redirect to this value when no value is provided by the client. |
| **`redirect_whitelist`** (`nil`) | As an added security measure, you can limit the URLs to which the API will redirect after email token validation (password reset, email confirmation, etc.). This value should be an array containing matches to the client URLs to be visited after validation. Wildcards are supported. |
| **`enable_standard_devise_support`** (`false`) |  By default, only Bearer Token authentication is implemented out of the box. If, however, you wish to integrate with legacy Devise authentication, you can do so by enabling this flag. NOTE: This feature is highly experimental! |
| **`remove_tokens_after_password_reset`** (`false`) | By default, old tokens are not invalidated when password is changed. Enable this option if you want to make passwords updates to logout other devices. |
| **`default_callbacks`**  (`true`) |  By default User model will include the `DeviseTokenAuth::Concerns::UserOmniauthCallbacks` concern, which has `email`, `uid` validations & `uid` synchronization callbacks. |
| **`cookie_enabled`** (`false`) | Specifies if DeviseTokenAuth should send and receive the auth token in a cookie.
| **`cookie_name`** (`"auth_cookie"`) | Sets the name of the cookie containing the auth token.
| **`cookie_attributes`** (`{}`) | Sets attributes for the cookie containing the auth token (ex. `domain`, `secure`, `httponly`, `same_site`, `expires`, `encrypt`). See [this Rails doc](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html) for what values can be passed to `ActionDispatch::Cookies`. See [this MDN doc](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies) for additional information on HTTP cookie attributes.
| **`bypass_sign_in`** (`true`) | By default DeviseTokenAuth will not check user's `#active_for_authentication?` which includes confirmation check on each call (it will do it only on sign in). If you want it to be validated on each request (for example, to be able to deactivate logged in users on the fly), set it to false. |
| **`send_confirmation_email`** (`false`) | By default DeviseTokenAuth will not send confirmation email, even when including devise confirmable module. If you want to use devise confirmable module and send email, set it to true. (This is a setting for compatibility) |
| **`require_client_password_reset_token`** (`false`) | By default, the password-reset confirmation link redirects to the client with valid session credentials as querystring params. With this option enabled, the redirect will NOT include the valid session credentials. Instead the redirect will include a password_reset_token querystring param that can be used to reset the users password. Once the user has reset their password, the password-reset success response headers will contain valid session credentials. |

Additionally, you can configure other aspects of devise by manually creating the traditional devise.rb file at `config/initializers/devise.rb`. Here are some examples of what you can do in this file:

~~~ruby
Devise.setup do |config|
  # The e-mail address that mail will appear to be sent from
  # If absent, mail is sent from "please-change-me-at-config-initializers-devise@example.com"
  config.mailer_sender = "support@myapp.com"

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # If using rails-api, you may want to tell devise to not use ActionDispatch::Flash
  # middleware b/c rails-api does not include it.
  # See: https://stackoverflow.com/q/19600905/806956
  config.navigational_formats = [:json]
end
~~~
