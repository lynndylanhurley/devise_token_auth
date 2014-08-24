![Serious Trust](https://github.com/lynndylanhurley/devise_token_auth/raw/master/test/dummy/app/assets/images/logo.jpg "Serious Trust")

[![Gem Version](https://badge.fury.io/rb/devise_token_auth.svg)](http://badge.fury.io/rb/devise_token_auth)
[![Build Status](https://travis-ci.org/lynndylanhurley/devise_token_auth.svg?branch=master)](https://travis-ci.org/lynndylanhurley/devise_token_auth)
[![Code Climate](http://img.shields.io/codeclimate/github/lynndylanhurley/devise_token_auth.svg)](https://codeclimate.com/github/lynndylanhurley/devise_token_auth)
[![Test Coverage](http://img.shields.io/codeclimate/coverage/github/lynndylanhurley/devise_token_auth.svg)](https://codeclimate.com/github/lynndylanhurley/devise_token_auth)
[![Dependency Status](https://gemnasium.com/lynndylanhurley/devise_token_auth.svg)](https://gemnasium.com/lynndylanhurley/devise_token_auth)

## Simple, secure token based authentication for Rails.

This gem provides the following features:

* Seamless integration with the the venerable [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module for [angular.js](https://github.com/angular/angular.js).
* Oauth2 authentication using [OmniAuth](https://github.com/intridea/omniauth).
* Email authentication using [Devise](https://github.com/plataformatec/devise), including:
  * User registration
  * Password reset
* Support for [multiple user models](https://github.com/lynndylanhurley/devise_token_auth#using-multiple-models).
* It is [secure](#security).

# Demo

[Here is a demo](http://ng-token-auth-demo.herokuapp.com/) of this app running with the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module.

The fully configured api used in the demo can be found [here](https://github.com/lynndylanhurley/devise_token_auth_demo).

# Dependencies
This project leverages the following gems:

* [Devise](https://github.com/plataformatec/devise)
* [OmniAuth](https://github.com/intridea/omniauth)

# Installation
Add the following to your `Gemfile`:

~~~ruby
gem devise_token_auth
~~~

Then install the gem using bundle:

~~~bash
bundle install
~~~

# Configuration TL;DR

You will need to create a [user model](#model-concerns), [define routes](#mounting-routes), [include concerns](#controller-concerns), and you may want to alter some of the [default settings](#initializer-settings) for this gem. Run the following command for an easy one-step installation:

~~~bash
rails g devise_token_auth:install [USER_CLASS] [MOUNT_PATH]
~~~

This generator accepts the following optional arguments:

| Argument | Default | Description |
|---|---|---|
| USER_CLASS | `User` | The name of the class to use for user authentication. |
| MOUNT_PATH | `auth` | The path at which to mount the authentication routes. [Read more](#usage). |

The following events will take place when using the install generator:

* An initializer will be created at `config/initializers/devise_token_auth.rb`. [Read more](#initializer-settings).

* A model will be created in the `app/models` directory. If the model already exists, a concern will be included at the top of the file. [Read more](#model-concerns).

* Routes will be appended to file at `config/routes.rb`. [Read more](#mounting-routes).

* A concern will be included by your application controller at `app/controllers/application_controller.rb`. [Read more](#controller-concerns).

* A migration file will be created in the `db/migrate` directory. Inspect the migrations file, add additional columns if necessary, and then run the migration:

  ~~~bash
  rake db:migrate
  ~~~

You may also need to configure the following items:

* **OmniAuth providers** when using 3rd party oauth2 authentication. [Read more](#omniauth-authentication).
* **Cross Origin Request Settings** when using cross-domain clients. [Read more](#cors).
* **Email** when using email registration. [Read more](#email-authentication).
* **Multiple model support** may require additional steps. [Read more](#using-multiple-models).

[Jump here](#configuration-cont) for more configuration information.

# Usage TL;DR

The following routes are available for use by your client. These routes live relative to the path at which this engine is mounted (`/auth` by default). These routes correspond to the defaults used by the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module for angular.js.

| path | method | purpose |
|:-----|:-------|:--------|
| /    | POST   | email registration. accepts **`email`**, **`password`**, and **`password_confirmation`** params. |
| /sign_in | POST | email authentication. accepts **`email`** and **`password`** as params. |
| /sign_out | DELETE | invalidate tokens (end session) |
| /:provider | GET | set this route as the destination for client authentication. ideally this will happen in an external window or popup. [Read more](#omniauth-authentication). |
| /:provider/callback | GET/POST | destination for the oauth2 provider's callback uri. `postMessage` events containing the authenticated user's data will be sent back to the main client window from this page. [Read more](#omniauth-authentication). |
| /validate_token | POST | use this route to validate tokens on return visits to the client. accepts **`uid`** and **`auth_token`** as params. these values should correspond to the columns in your `User` table of the same names. |
| /password | POST | send password email to users that registered by email. accepts **`email`** and **`redirect_url`** as params. The user matching the `email` param will be sent instructions on how to reset their password. `redirect_url` is the url to which the user will be redirected after visiting the link contained in the email. |
| /password | PUT | password change for users that registered by email. accepts **`password`** and **`password_confirmation`** as params. |
| /password/edit | GET | verify user by password reset token. must contain **`reset_password_token`** and **`redirect_url`** as params. These values will be set automatically by the confirmation email that is generated by the password reset request. |

[Jump here](#usage-cont) for more usage information.

# Configuration cont.

## Initializer settings

The following settings are available for configuration in `config/initializers/devise_token_auth.rb`:

| Name | Default | Description|
|---|---|---|
| **`change_headers_on_each_request`** | `true` | By default the access_token header will change after each request. The client is responsible for keeping track of the changing tokens. The [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module for angular.js does this out of the box. While this implementation is more secure, it can be difficult to manage. Set this to false to prevent the `access_token` header from changing after each request. [Read more](#about-token-management). |
| **`token_lifespan`** | `2.weeks` | Set the length of your tokens' lifespans. Users will need to re-authenticate after this duration of time has passed since their last login. |
| **`batch_request_buffer_throttle`** | `5.seconds` | Sometimes it's necessary to make several requests to the API at the same time. In this case, each request in the batch will need to share the same auth token. This setting determines how far apart the requests can be while still using the same auth token. [Read more](#about-batch-requests). |
| **`omniauth_prefix`** | `"/omniauth"` | This route will be the prefix for all oauth2 redirect callbacks. For example, using the default '/omniauth' setting, the github oauth2 provider will redirect successful authentications to '/omniauth/github/callback'. [Read more](#omniauth-provider-settings). |


## OmniAuth authentication

If you wish to use omniauth authentication, add all of your desired authentication provider gems to your `Gemfile`.

**OmniAuth example using github, facebook, and google**:
~~~ruby
gem 'omniauth-github'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
~~~

Then run `bundle install`.

[List of oauth2 providers](https://github.com/intridea/omniauth/wiki/List-of-Strategies)

## OmniAuth provider settings

In `config/initializers/omniauth.rb`, add the settings for each of your providers.

These settings must be obtained from the providers themselves.

**Example using github, facebook, and google**:
~~~ruby
# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,        ENV['GITHUB_KEY'],   ENV['GITHUB_SECRET'],   scope: 'email,profile'
  provider :facebook,      ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :google_oauth2, ENV['GOOGLE_KEY'],   ENV['GOOGLE_SECRET']
end
~~~

The above example assumes that your provider keys and secrets are stored in environmental variables. Use the [figaro](https://github.com/laserlemon/figaro) gem (or [dotenv](https://github.com/bkeepers/dotenv) or [secrets.yml](https://github.com/rails/rails/blob/v4.1.0/railties/lib/rails/generators/rails/app/templates/config/secrets.yml) or equivalent) to accomplish this.

#### OmniAuth callback settings

The "Callback URL" setting that you set with your provider must correspond to the [omniauth prefix](#initializer-settings) setting defined by this app. **This will be different than the omniauth route that is used by your client application**.

For example, the demo app uses the default `omniauth_prefix` setting `/omniauth`, so the "Authorization callback URL" for github must be set to "http://devise-token-auth-demo.herokuapp.com**/omniauth**/github/callback".

**Github example for the demo site**:
![password reset flow](https://github.com/lynndylanhurley/devise_token_auth/raw/master/test/dummy/app/assets/images/omniauth-provider-settings.png)

The url for github authentication will be different for the client. The client should visit the API at `/[MOUNT_PATH]/:provider` for omniauth authentication.

For example, given that the app is mounted using the following settings:

~~~ruby
# config/routes.rb
mount_devise_token_auth_for 'User', at: '/auth'
~~~

The client configuration for github should look like this:

**Angular.js setting for authenticating using github**:
~~~javascript
angular.module('myApp', ['ng-token-auth'])
  .config(function($authProvider) {
    $authProvider.configure({
      apiUrl: 'http://api.example.com'
      authProviderPaths: {
        github: '/auth/github' // <-- note that this is different than what was set with github
      }
    });
  });
~~~

This incongruence is necessary to support multiple user classes and mounting points.

#### Note for [pow](http://pow.cx/) and [xip.io](http://xip.io) users

If you receive `redirect-uri-mismatch` errors from your provider when using pow or xip.io urls, set the following in your development config:

~~~ruby
# config/environments/development.rb

# when using pow
OmniAuth.config.full_host = "http://app-name.dev"

# when using xip.io
OmniAuth.config.full_host = "http://xxx.xxx.xxx.app-name.xip.io"
~~~

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

## CORS

If your API and client live on different domains, you will need to configure your Rails API to allow [cross origin requests](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing). The [rack-cors](https://github.com/cyu/rack-cors) gem can be used to accomplish this.

The following **dangerous** example will allow cross domain requests from **any** domain. Make sure to whitelist only the needed domains.

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
          :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
          :methods => [:get, :post, :options, :delete, :put]
      end
    end
  end
end
~~~

Make extra sure that the `Access-Control-Expose-Headers` includes `access-token`, `expiry`, `token-type`, `uid`, and `client` (as is set in the example above by the`:expose` param). If your client experiences erroneous 401 responses, this is likely the cause.

CORS may not be possible with older browsers (IE8, IE9). I usually set up a proxy for those browsers. See the [ng-token-auth readme](https://github.com/lynndylanhurley/ng-token-auth) for more information.

# Usage cont.

## Mounting Routes

The authentication routes must be mounted to your project. This gem includes a route helper for this purpose:

**`mount_devise_token_auth_for`** - similar to `devise_for`, this method is used to append the routes necessary for user authentication. This method accepts the following arguments:

| Argument | Type | Default | Description |
|---|---|---|---|
|`class_name`| string | 'User' | The name of the class to use for authentication. This class must include the [model concern described here](#model-concerns). |
| `options` | object | {at: '/auth'} | The [routes to be used for authentication](#usage) will be prefixed by the path specified in the `at` param of this object. |

**Example**:
~~~ruby
# config/routes.rb
mount_devise_token_auth_for 'User', at: '/auth'
~~~

Any model class can be used, but the class will need to include [`DeviseTokenAuth::Concerns::SetUserByToken`](#model-concerns) for authentication to work properly.

You can mount this engine to any route that you like. `/auth` is used by default to conform with the defaults of the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module.


## Controller Concerns

##### DeviseTokenAuth::Concerns::SetUserByToken

This gem includes a [Rails concern](http://api.rubyonrails.org/classes/ActiveSupport/Concern.html) called `DeviseTokenAuth::Concerns::SetUserByToken`. This concern can be used in controllers to identify users by their authentication headers.

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

The authentication information should be included by the client in the headers of each request. The headers follow the [RFC 6750 Bearer Token](http://tools.ietf.org/html/rfc6750) format:

##### Authentication headers example:
~~~
"access_token": "wwwww",
"token_type":   "Bearer",
"client":       "xxxxx",
"expiry":       "yyyyy",
"uid":          "zzzzz"
~~~

The authentication headers consists of the following params:

| param | description |
|---|---|
| **`access_token`** | This serves as the user's password for each request. A hashed version of this value is stored in the database for later comparison. This value should be changed on each request. |
| **`client`** | This enables the use of multiple simultaneous sessions on different clients. (For example, a user may want to be authenticated on both their phone and their laptop at the same time.) |
| **`expiry`** | The date at which the current session will expire. This can be used by clients to invalidate expired tokens without the need for an API request. |
| **`uid`** | A unique value that is used to identify the user. This is necessary because searching the DB for users by their access token will make the API susceptible to [timing attacks](http://codahale.com/a-lesson-in-timing-attacks/). |

The authentication headers required for each request will be available in the response from the previous request. If you are using the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module for angular.js, this functionality is already provided.

## Model Concerns

##### DeviseTokenAuth::Concerns::SetUserByToken

Typical use of this gem will not require the use of any of the following model methods. All authentication should be handled invisibly by the [controller concerns](#controller-concerns) described above.

Models that include the `DeviseTokenAuth::Concerns::SetUserByToken` concern will have access to the following public methods (read the above section for context on `token` and `client`):

* **`valid_token?`**: check if an authentication token is valid. Accepts a `token` and `client` as arguments. Returns a boolean.

  **Example**:
  ~~~ruby
  # extract token + client_id from auth header
  client_id = request.headers['client']
  token = request.headers['access_token']

  @user.valid_token?(token, client_id)
  ~~~

* **`create_new_auth_token`**: creates a new auth token with all of the necessary metadata. Accepts `client` as an optional argument. Will generate a new `client` if none is provided. Returns the authentication headers that should be sent by the client as an object.

  **Example**:
  ~~~ruby
  # extract client_id from auth header
  client_id = request.headers['client']

  # update token, generate updated auth headers for response
  new_auth_header = @user.create_new_auth_token(client_id)

  # update response with the header that will be required by the next request
  response.headers.merge!(new_auth_header)
  ~~~

* **`build_auth_header`**: generates the auth header that should be sent to the client with the next request. Accepts `token` and `client` as arguments. Returns a string.

  **Example**:
  ~~~ruby
  # create client id and token
  client_id = SecureRandom.urlsafe_base64(nil, false)
  token     = SecureRandom.urlsafe_base64(nil, false)

  # store client + token in user's token hash
  @user.tokens[client_id] = {
    token: BCrypt::Password.create(token),
    expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
  }

  # generate auth headers for response
  new_auth_header = @user.build_auth_header(token, client_id)

  # update response with the header that will be required by the next request
  response.headers.merge!(new_auth_header)
  ~~~

## Using multiple models

This gem supports the use of multiple user models. One possible use case is to authenticate visitors using a model called `User`, and to authenticate administrators with a model called `Admin`. Take the following steps to add another authentication model to your app:

1. Run the install generator for the new model.
  ~~~
  rails g devise_token_auth:install Admin admin_auth
  ~~~

  This will create the `Admin` model and define the model's authentication routes with the base path `/admin_auth`.

1. Define the routes to be used by the `Admin` user within a [`devise_scope`](https://github.com/plataformatec/devise#configuring-routes).

  **Example**:
  ~~~ruby
  Rails.application.routes.draw do
    # when using multiple models, controllers will default to the first available
    # devise mapping. routes for subsequent devise mappings will need to defined
    # within a `devise_scope` block

    # define :users as the first devise mapping:
    mount_devise_token_auth_for 'User', at: '/auth'

    # define :admins as the second devise mapping. routes using this class will
    # need to be defined within a devise_scope as shown below
    mount_devise_token_auth_for "Admin", at: '/admin_auth'

    # this route will authorize requests using the User class
    get 'demo/members_only', to: 'demo#members_only'

    # routes within this block will authorize requests using the Admin class
    devise_scope :admin do
      get 'demo/admins_only', to: 'demo#admins_only'
    end
  end
  ~~~

# Conceptual

None of the following information is required to use this gem, but read on if you're curious.

## About token management

Tokens should be invalidated after each request to the API. The following diagram illustrates this concept:

![password reset flow](https://github.com/lynndylanhurley/ng-token-auth/raw/master/test/app/images/flow/token-update-detail.jpg)

During each request, a new token is generated. The `access_token` header that should be used in the next request is returned in the `access_token` header of the response to the previous request. The last request in the diagram fails because it tries to use a token that was invalidated by the previous request.

The only case where an expired token is allowed is during [batch requests](#about-batch-requests).

These measures are taken by default when using this gem.

## About batch requests

By default, the API should update the auth token for each request ([read more](#about-token-management)). But sometimes it's neccessary to make several concurrent requests to the API, for example:

#####Batch request example
~~~javascript
$scope.getResourceData = function() {

  $http.get('/api/restricted_resource_1').success(function(resp) {
    // handle response
    $scope.resource1 = resp.data;
  });

  $http.get('/api/restricted_resource_2').success(function(resp) {
    // handle response
    $scope.resource2 = resp.data;
  });
};
~~~

In this case, it's impossible to update the `access_token` header for the second request with the `access_token` header of the first response because the second request will begin before the first one is complete. The server must allow these batches of concurrent requests to share the same auth token. This diagram illustrates how batch requests are identified by the server:

![batch request overview](https://github.com/lynndylanhurley/ng-token-auth/raw/master/test/app/images/flow/batch-request-overview.jpg)

The "5 second" buffer in the diagram is the default used this gem.

The following diagram details the relationship between the client, server, and access tokens used over time when dealing with batch requests:

![batch request detail](https://github.com/lynndylanhurley/ng-token-auth/raw/master/test/app/images/flow/batch-request-detail.jpg)

Note that when the server identifies that a request is part of a batch request, the user's auth token is not updated. The auth token will be updated for the first request in the batch, and then that same token will be returned in the responses for each subsequent request in the batch (as shown in the diagram).

This gem automatically manages batch requests. You can change the time buffer for what is considered a batch request using the `batch_request_buffer_throttle` parameter in `config/initializers/devise_token_auth.rb`.


# Security

This gem takes the following steps to ensure security.

This gem uses auth tokens that are:
* [changed after every request](#about-token-management),
* [of cryptographic strength](http://ruby-doc.org/stdlib-2.1.0/libdoc/securerandom/rdoc/SecureRandom.html),
* hashed using [BCrypt](https://github.com/codahale/bcrypt-ruby) (not stored in plain-text),
* securely compared (to protect against timing attacks),
* invalidated after 2 weeks (thus requiring users to login again)

These measures were inspired by [this stackoverflow post](http://stackoverflow.com/questions/18605294/is-devises-token-authenticatable-secure).

This gem further mitigates timing attacks by using [this technique](https://gist.github.com/josevalim/fb706b1e933ef01e4fb6).

But the most important step is to use HTTPS. You are on the hook for that.


# Contributing
Just send a pull request. I will grant you commit access if you send quality pull requests.

Guidelines will be posted if the need arises.

# License
This project uses the WTFPL
