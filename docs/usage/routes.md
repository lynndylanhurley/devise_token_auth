## Mounting Routes

The authentication routes must be mounted to your project. This gem includes a route helper for this purpose:

**`mount_devise_token_auth_for`** - similar to `devise_for`, this method is used to append the routes necessary for user authentication. This method accepts the following arguments:

| Argument | Type | Default | Description |
|---|---|---|---|
|`class_name`| string | 'User' | The name of the class to use for authentication. This class must include the [model concern described here](#model-concerns). |
| `options` | object | {at: 'auth'} | The [routes to be used for authentication](#usage) will be prefixed by the path specified in the `at` param of this object. |

**Example**:
~~~ruby
# config/routes.rb
mount_devise_token_auth_for 'User', at: 'auth'
~~~

Any model class can be used, but the class will need to include [`DeviseTokenAuth::Concerns::User`](model_concerns.md) for authentication to work properly.

You can mount this engine to any route that you like. `/auth` is used by default to conform with the defaults of the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module and the [jToker](https://github.com/lynndylanhurley/j-toker) plugin.
