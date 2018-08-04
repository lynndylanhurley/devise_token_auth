## Controller Methods

### Concerns

This gem includes a [Rails concern](http://api.rubyonrails.org/classes/ActiveSupport/Concern.html) called `DeviseTokenAuth::Concerns::SetUserByToken`. Include this concern to provide access to controller methods such as `authenticate_user!`, `user_signed_in?`, etc.

The concern also runs an [after_action](http://guides.rubyonrails.org/action_controller_overview.html#filters) that changes the auth token after each request.

It is recommended to include the concern in your base `ApplicationController` so that all children of that controller include the concern as well.

##### Concern example:

~~~ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
end
~~~

### Methods

This gem provides access to all of the following [devise helpers](https://github.com/plataformatec/devise#controller-filters-and-helpers):

| Method | Description |
|---|---|
| **`before_action :authenticate_user!`** | Returns a 401 error unless a `User` is signed-in. |
| **`current_user`** | Returns the currently signed-in `User`, or `nil` if unavailable. |
| **`user_signed_in?`** | Returns `true` if a `User` is signed in, otherwise `false`. |
| **`devise_token_auth_group`** | Operate on multiple user classes as a group. [Read more](#group-access) |

Note that if the model that you're trying to access isn't called `User`, the helper method names will change. For example, if the user model is called `Admin`, the methods would look like this:

* `before_action :authenticate_admin!`
* `admin_signed_in?`
* `current_admin`


##### Example: limit access to authenticated users
~~~ruby
# app/controllers/test_controller.rb
class TestController < ApplicationController
  before_action :authenticate_user!

  def members_only
    render json: {
      data: {
        message: "Welcome #{current_user.name}",
        user: current_user
      }
    }, status: 200
  end
end
~~~

### Token Header Format

The authentication information should be included by the client in the headers of each request. The headers follow the [RFC 6750 Bearer Token](https://tools.ietf.org/html/rfc6750) format:

##### Authentication headers example:
~~~
"access-token": "wwwww",
"token-type":   "Bearer",
"client":       "xxxxx",
"expiry":       "yyyyy",
"uid":          "zzzzz"
~~~

The authentication headers (each one is a seperate header) consists of the following params:

| param | description |
|---|---|
| **`access-token`** | This serves as the user's password for each request. A hashed version of this value is stored in the database for later comparison. This value should be changed on each request. |
| **`client`** | This enables the use of multiple simultaneous sessions on different clients. (For example, a user may want to be authenticated on both their phone and their laptop at the same time.) |
| **`expiry`** | The date at which the current session will expire. This can be used by clients to invalidate expired tokens without the need for an API request. |
| **`uid`** | A unique value that is used to identify the user. This is necessary because searching the DB for users by their access token will make the API susceptible to [timing attacks](https://codahale.com/a-lesson-in-timing-attacks/). |

The authentication headers required for each request will be available in the response from the previous request. If you are using the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) AngularJS module or the [jToker](https://github.com/lynndylanhurley/j-toker) jQuery plugin, this functionality is already provided.
