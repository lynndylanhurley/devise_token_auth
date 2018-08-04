## Custom Controller Overrides

The built-in controllers can be overridden with your own custom controllers.

For example, the default behavior of the [`validate_token`](https://github.com/lynndylanhurley/devise_token_auth/blob/8a33d25deaedb4809b219e557e82ec7ec61bf940/app/controllers/devise_token_auth/token_validations_controller.rb#L6) method of the [`TokenValidationController`](https://github.com/lynndylanhurley/devise_token_auth/blob/8a33d25deaedb4809b219e557e82ec7ec61bf940/app/controllers/devise_token_auth/token_validations_controller.rb) is to return the `User` object as json (sans password and token data). The following example shows how to override the `validate_token` action to include a model method as well.

##### Example: controller overrides

~~~ruby
# config/routes.rb
Rails.application.routes.draw do
  ...
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    token_validations:  'overrides/token_validations'
  }
end

# app/controllers/overrides/token_validations_controller.rb
module Overrides
  class TokenValidationsController < DeviseTokenAuth::TokenValidationsController

    def validate_token
      # @resource will have been set by set_user_by_token concern
      if @resource
        render json: {
          data: @resource.as_json(methods: :calculate_operating_thetan)
        }
      else
        render json: {
          success: false,
          errors: ["Invalid login credentials"]
        }, status: 401
      end
    end
  end
end
~~~

## Overriding rendering methods
To customize json rendering, implement the following protected controller methods, for success methods, assume that the @resource object is available:

### Registrations Controller
* render_create_error_missing_confirm_success_url
* render_create_error_redirect_url_not_allowed
* render_create_success
* render_create_error
* render_create_error_email_already_exists
* render_update_success
* render_update_error
* render_update_error_user_not_found


### Sessions Controller
* render_new_error
* render_create_success
* render_create_error_not_confirmed
* render_create_error_bad_credentials
* render_destroy_success
* render_destroy_error


### Passwords Controller
* render_create_error_missing_email
* render_create_error_missing_redirect_url
* render_create_error_not_allowed_redirect_url
* render_create_success
* render_create_error
* render_update_error_unauthorized
* render_update_error_password_not_required
* render_update_error_missing_password
* render_update_success
* render_update_error

### Token Validations Controller
* render_validate_token_success
* render_validate_token_error

##### Example: all :controller options with default settings:

~~~ruby
mount_devise_token_auth_for 'User', at: 'auth', controllers: {
  confirmations:      'devise_token_auth/confirmations',
  passwords:          'devise_token_auth/passwords',
  omniauth_callbacks: 'devise_token_auth/omniauth_callbacks',
  registrations:      'devise_token_auth/registrations',
  sessions:           'devise_token_auth/sessions',
  token_validations:  'devise_token_auth/token_validations'
}
~~~

**Note:** Controller overrides must implement the expected actions of the controllers that they replace.

## Passing blocks to Controllers

It may be that you simply want to _add_ behavior to existing controllers without having to re-implement their behavior completely. In this case, you can do so by creating a new controller that inherits from any of DeviseTokenAuth's controllers, overriding whichever methods you'd like to add behavior to by  passing a block to `super`:

```ruby
class Custom::RegistrationsController < DeviseTokenAuth::RegistrationsController

  def create
    super do |resource|
      resource.do_something(extra)
    end
  end

end
```

Your block will be performed just before the controller would usually render a successful response.

## Email Template Overrides

You will probably want to override the default email templates for email sign-up and password-reset confirmation. Run the following command to copy the email templates into your app:

~~~bash
rails generate devise_token_auth:install_views
~~~

This will create two new files:

* `app/views/devise/mailer/reset_password_instructions.html.erb`
* `app/views/devise/mailer/confirmation_instructions.html.erb`

These files may be edited to suit your taste. You can customize the e-mail subjects like [this](/docs/config/devise.md).

**Note:** if you choose to modify these templates, do not modify the `link_to` blocks unless you absolutely know what you are doing.
