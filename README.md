# Devise Token Auth

![build](https://travis-ci.org/lynndylanhurley/devise_token_auth.svg)

This gem provides simple, secure token based authentication.

This gem was designed to work with the venerable [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module for [angular.js](https://github.com/angular/angular.js).

# Demo

[Here is a demo](http://ng-token-auth-demo.herokuapp.com/) of this app running with the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module.

The fully configured api used in the demo can be found [here](https://github.com/lynndylanhurley/devise_token_auth_demo).

# Dependencies
This project leverages the following gems:

* [Devise](https://github.com/plataformatec/devise)
* [Omniauth](https://github.com/intridea/omniauth)

# Installation
Add the following to your `Gemfile`:

~~~ruby
gem devise_token_auth
~~~

Then install the gem using bundle:

~~~bash
bundle install
~~~

## Configuration
You will need to create a user model, and you may want to alter some of the default settings. Run the following to generate the migrations and initializer files:

~~~bash
rails g devise_token_auth:install
~~~

This will create a migrations file in the `db/migrate` directory. Inspect the migrations file and add additional columns if necessary, then run the migration:

~~~bash
rake db:migrate
~~~

An initializer will also be created at `config/initializers/devise_token_auth.rb`. The following settings are available for configuration:

* **`change_headers_on_each_request`** _Default: true_. By default the authorization headers will change after each request. The client is responsible for keeping track of the changing tokens. The [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module for angular.js does this out of the box. While this implementation is more secure, it can be difficult to manage. Set this to false to prevent the `Authorization` header from changing after each request.
*  **`token_lifespan`** _Default: 2.weeks_. Set the length of your tokens' lifespans. Users will need to re-authenticate after this duration of time has passed since their last login.
*  **`batch_request_buffer_throttle`** _Default: 2.seconds_. Sometimes it's necessary to make several requests to the API at the same time. In this case, each request in the batch will need to share the same auth token. This setting determines how far apart the requests can be while still using the same auth token.

## Omniauth authentication

If you wish to use omniauth authentication, add all of your desired authentication provider gems as well.

##### Omniauth example using github, facebook, and google:
~~~ruby
gem 'omniauth-github',        :git => 'git://github.com/intridea/omniauth-github.git'
gem 'omniauth-facebook',      :git => 'git://github.com/mkdynamic/omniauth-facebook.git'
gem 'omniauth-google-oauth2', :git => 'git://github.com/zquestz/omniauth-google-oauth2.git'
~~~

Then run `bundle install`.

[List of oauth2 providers](https://github.com/intridea/omniauth/wiki/List-of-Strategies)

#### Provider settings
In `config/initializers/omniauth.rb`, add the settings for each of your providers.

These settings must be obtained from the providers themselves.

##### Example using github, facebook, and google:
~~~ruby
# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,        ENV['GITHUB_KEY'],   ENV['GITHUB_SECRET'],   scope: 'email,profile'
  provider :facebook,      ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :google_oauth2, ENV['GOOGLE_KEY'],   ENV['GOOGLE_SECRET']
end
~~~

The above example assumes that your provider keys and secrets are stored in environmental variables. Use the [figaro](https://github.com/laserlemon/figaro) gem (or [dotenv](https://github.com/bkeepers/dotenv) or [secrets.yml](https://github.com/rails/rails/blob/v4.1.0/railties/lib/rails/generators/rails/app/templates/config/secrets.yml) or equivalent) to accomplish this.


**Note for [pow](http://pow.cx/) and [xip.io](http://xip.io) users**: if you receive `redirect-uri-mismatch` errors from your provider when using pow or xip.io urls, set the following in your development config:

~~~ruby
# config/environments/development.rb

# when using pow
OmniAuth.config.full_host = "http://app-name.dev"

# when using xip.io
OmniAuth.config.full_host = "http://xxx.xxx.xxx.app-name.xip.io"
~~~

There may be a better way to accomplish this. Please post an issue if you have any suggestions.

## Email authentication
If you wish to use email authentication, you must configure your Rails application to send email. [Read here](http://guides.rubyonrails.org/action_mailer_basics.html) for more information.

I recommend using [mailcatcher](http://mailcatcher.me/) for development.

##### mailcatcher development example configuration:
~~~ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_mailer.default_url_options = { :host => 'your-dev-host.dev' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :address => 'your-dev-host.dev', :port => 1025 }
end
~~~

## Routes

The authentication routes must be mounted to your project.

In `config/routes.rb`, add the following line:

~~~ruby
# config/routes.rb
mount DeviseTokenAuth::Engine => "/auth"
~~~

Note that you can mount this engine to any route that you like. `/auth` is used to conform to the defaults of the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module.

## CORS

If your API and client live on different domains, you will need to configure your Rails API to allow cross origin requests. The [rack-cors](https://github.com/cyu/rack-cors) gem can be used to accomplish this.

The following example will allow cross domain requests from any domain.

##### Example rack-cors configuration:
~~~ruby
# gemfile
gem 'rack-cors', :require => 'rack/cors'

# config/application.rb
module YourApp
  class Application < Rails::Application
    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*',
          :headers => :any,
          :expose => ['Authorization'], # <-- important!
          :methods => [:get, :post, :options, :delete, :put]
      end
    end
  end
end
~~~

Make extra sure that the `Access-Control-Expose-Headers` includes `Authorization` (as is set in the example above by the`:expose` param). If your client experiences erroneous 401 responses, this is likely the cause.

CORS may not be possible with older browsers (IE8, IE9). I usually set up a proxy for those browsers. See the [ng-token-auth readme](https://github.com/lynndylanhurley/ng-token-auth) for more information.

# Usage

The following routes are available for use by your client. These routes live relative to the path at which this engine is mounted (`/auth` in the example above).

| path | method | purpose |
|:-----|:-------|:--------|
| /    | POST   | email registration. accepts **`email`**, **`password`**, and **`password_confirmation`** params. |
| /sign_in | POST | email authentication. accepts **`email`** and **`password`** as params. |
| /sign_out | DELETE | invalidate tokens (end session) |
| /:provider | GET | set this route as the destination for client authentication. ideally this will happen in an external window or popup. |
| /:provider/callback | GET/POST | destination for the oauth2 provider's callback uri. `postMessage` events containing the authenticated user's data will be sent back to the main client window from this page. |
| /validate_token | POST | use this route to validate tokens on return visits to the client. accepts **`uid`** and **`auth_token`** as params. these values should correspond to the columns in your `User` table of the same names. |
| /password | POST | send password email to users that registered by email. accepts **`email`** and **`redirect_url`** as params. The user matching the `email` param will be sent instructions on how to reset their password. `redirect_url` is the url to which the user will be redirected after visiting the link contained in the email. |
| /password | PUT | password change for users that registered by email. accepts **`password`** and **`password_confirmation`** as params. |
| /password/edit | GET | verify user by password reset token. must contain **`reset_password_token`** and **`redirect_url`** as params. These values will be set automatically by the confirmation email that is generated by the password reset request. |

If you're using [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) for angular.js, then your client is ready to go.


## Identifying users in controllers

The authentication information should be included by the client in the `Authorization` header of each request. The header should follow this format:

##### Authorization header example:
~~~
token=wwwww client=xxxxx expiry=yyyyy uid=zzzzz
~~~

The `Authorization` header is made up of the following components:

* **`token`**: This serves as the user's password for each request. A hashed version of this value is stored in the database for later comparison. This value should be changed on each request.
* **`client`**: This enables the use of multiple simultaneous sessions on different clients. (For example, a user may want to be authenticated on both their phone and their laptop at the same time.)
* **`expiry`**: The date at which the current session will expire. This can be used by clients to invalidate expired tokens without the need for an API request.
* **`uid`**: A unique value that is used to identify the user. This is necessary because searching the DB for users by their access token will open the API up to timing attacks.

The `Authorization` header required for each request will be available in the response from the previous request. If you are using the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module for angular.js, this functionality is already provided.

## Handling batch requests

Sometimes it's necessary to send several concurrent requests to the API. In these cases, the concurrent requests will need to share the same auth token (tokens are usually changed after each request). [Read here](https://github.com/lynndylanhurley/ng-token-auth#about-batch-requests) for an overview on how this gem deals with batch requests.

## The `User` model

The user model will contain the following public methods (read the above section for context on `token` and `client`):
* **`valid_token?`**: check if an authentication token is valid. Accepts `token` and `client` as arguments. Returns a boolean.
* **`create_new_auth_token`**: creates a new auth token with all of the necessary metadata. Accepts `client` as an optional argument. Will generate a new `client` if none is provided. Returns the `Authorization` header that should be sent by the client as a string.
* **`build_auth_header`**: generates the auth header that should be sent to the client with the next request. Accepts `token` and `client` as arguments. Returns a string.

## DeviseTokenAuth::Concerns::SetUserByToken

This gem includes a [Rails concern](http://api.rubyonrails.org/classes/ActiveSupport/Concern.html) that can be used to identify users by the `Authorization` header.

This concern runs a [before_action](http://guides.rubyonrails.org/action_controller_overview.html#filters), setting the `@user` variable for use in your controllers. The user will be signed in via devise for the duration of the request.

The concern also runs an [after_action](http://guides.rubyonrails.org/action_controller_overview.html#filters) that changes the auth token after each request.

It is recommended to include the concern in your base `ApplicationController` so that all children of that controller include the concern as well.

~~~ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
end

# app/controllers/test_controller.rb
class TestController < ApplicationController
  def members_only
    if @user
      render json: {
        data: {
          message: "Welcome #{@user.name}",
          user: @user
        }
      }, status: 200
    else
      render json: {
        errors: ["Authorized users only."]
      }, status: 401
    end
  end
end
~~~

# Security

This gem takes the following steps to ensure security.

This gem uses auth tokens that are:
* changed after every request,
* [of cryptographic strength](http://ruby-doc.org/stdlib-2.1.0/libdoc/securerandom/rdoc/SecureRandom.html),
* hashed using [BCrypt](https://github.com/codahale/bcrypt-ruby) (not stored in plain-text),
* securely compared (to protect against timing attacks),
* invalidated after 2 weeks

These measures were inspired by [this stackoverflow post](http://stackoverflow.com/questions/18605294/is-devises-token-authenticatable-secure).

This gem further mitigates timing attacks by using [this technique](https://gist.github.com/josevalim/fb706b1e933ef01e4fb6).

But the most important step is to use HTTPS. You are on the hook for that.

# TODO

* Write tests
* `User` model is currently baked into this gem. Allow for dynamic definition using concerns (or other means).
* Find a way to expose devise + omniauth configs, maybe using generators.

# Contributing
Just send a pull request. I will grant you commit access if you send quality pull requests.

Guidelines will be posted if the need arises.

# License
This project uses the WTFPL
