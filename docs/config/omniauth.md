# OmniAuth

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

The "Callback URL" setting that you set with your provider must correspond to the [omniauth prefix](initialization.md) setting defined by this app. **This will be different than the omniauth route that is used by your client application**.

For example, the demo app uses the default `omniauth_prefix` setting `/omniauth`, so the "Authorization callback URL" for github must be set to "https://devise-token-auth-demo.herokuapp.com**/omniauth**/github/callback".

**Github example for the demo site**:
![password reset flow](https://github.com/lynndylanhurley/devise_token_auth/raw/master/test/dummy/app/assets/images/omniauth-provider-settings.png)

The url for github authentication will be different for the client. The client should visit the API at `/[MOUNT_PATH]/:provider` for omniauth authentication.

For example, given that the app is mounted using the following settings:

~~~ruby
# config/routes.rb
mount_devise_token_auth_for 'User', at: 'auth'
~~~

The client configuration for github should look like this:

**Angular.js setting for authenticating using github**:
~~~javascript
angular.module('myApp', ['ng-token-auth'])
  .config(function($authProvider) {
    $authProvider.configure({
      apiUrl: 'https://api.example.com'
      authProviderPaths: {
        github: '/auth/github' // <-- note that this is different than what was set with github
      }
    });
  });
~~~

**jToker settings for github should look like this:**

~~~javascript
$.auth.configure({
  apiUrl: 'https://api.example.com',
  authProviderPaths: {
    github: '/auth/github' // <-- note that this is different than what was set with github
  }
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
