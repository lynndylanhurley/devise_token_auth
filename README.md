# DeviseTokenAuth
This module handles the boilerplate of configuring a token based authentication API for rails. 

# Dependencies
This project leverages the following gems:

* [Devise](https://github.com/plataformatec/devise)
* [Omniauth](https://github.com/intridea/omniauth)

This gem was designed to work with the venerable [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module for [angular.js](https://github.com/angular/angular.js).

# Installation
Add the following to your `Gemfile`:

~~~ruby
gem devise_token_auth
~~~

Then install the gem using bundle:

~~~bash
bundle install
~~~

## Migrations
You will need to create a user model. Run the following to generate and run the `User` model migration:

~~~bash
rails generate devise_token_auth:install:migrations
~~~

Then run the migration:

~~~bash
rake db:migrate
~~~

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

These settings must be obtained from the providers themselves. More information about providers can be found [here](https://github.com/intridea/omniauth/wiki/List-of-Strategies).

##### Example using github, facebook, and google:
~~~ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,        ENV['GITHUB_KEY'],   ENV['GITHUB_SECRET'],   scope: 'email,profile'
  provider :facebook,      ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :google_oauth2, ENV['GOOGLE_KEY'],   ENV['GOOGLE_SECRET']
end
~~~

The above example assumes that your provider keys and secrets are stored in environmental variables. Use the [figaro](https://github.com/laserlemon/figaro) gem (or equivalent) to accomplish this.

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
mount DeviseTokenAuth::Engine => "/auth"
~~~

Note that you can mount to any route that you like. `/auth` is used to conform to the defaults of the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module.

# Usage
If you're using the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) for angular.js, then you're already done.

The following routes are available for use by your client. These routes are relative to the path at which this engine is mounted (`/auth` in the example above).

| path | method | purpose |
|:-----|:-------|:--------|
| /    | POST   | email registration. accepts **email**, **password**, and **password_confirmation** params. |
| /sign_in | POST | email authentication. accepts **email** and **password** as params. |
| /sign_out | DELETE | invalidate tokens (end session) |
| /:provider | GET | set this route as the destination for client authentication. ideally this will happen in an external window or popup. |
| /:provider/callback | GET/POST | destination for the oauth2 provider's callback uri. `postMessage` events containing the authenticated user's data will be sent back to the main client window from this page. |
| /validate_token | POST | use this route to validate tokens on return visits to the client. accepts **uid** and **auth_token** as params. these values should correspond to the columns in your `User` table of the same names. |

# Contributing
Just send a pull request. I will grant you commit access if you consistently send quality pull requests.

Guidelines will be posted if the need arises.

# License
This project rocks and uses MIT-LICENSE.