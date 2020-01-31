## CORS

If your API and client live on different domains, you will need to configure your Rails API to allow [cross origin requests](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing). The [rack-cors](https://github.com/cyu/rack-cors) gem can be used to accomplish this.

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
          headers: :any,
          expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'],
          methods: [:get, :post, :options, :delete, :put]
      end
    end
  end
end
~~~

Make extra sure that the `Access-Control-Expose-Headers` includes `access-token`, `expiry`, `token-type`, `uid`, and `client` (as is set in the example above by the`:expose` param). If your client experiences erroneous 401 responses, this is likely the cause.

CORS may not be possible with older browsers (IE8, IE9). I usually set up a proxy for those browsers. See the [ng-token-auth readme](https://github.com/lynndylanhurley/ng-token-auth) or the [jToker readme](https://github.com/lynndylanhurley/j-toker) for more information.
