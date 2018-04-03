## Excluding Modules

By default, almost all of the Devise modules are included:
* [`database_authenticatable`](https://github.com/plataformatec/devise/blob/master/lib/devise/models/database_authenticatable.rb)
* [`registerable`](https://github.com/plataformatec/devise/blob/master/lib/devise/models/registerable.rb)
* [`recoverable`](https://github.com/plataformatec/devise/blob/master/lib/devise/models/recoverable.rb)
* [`trackable`](https://github.com/plataformatec/devise/blob/master/lib/devise/models/trackable.rb)
* [`validatable`](https://github.com/plataformatec/devise/blob/master/lib/devise/models/validatable.rb)
* [`confirmable`](https://github.com/plataformatec/devise/blob/master/lib/devise/models/confirmable.rb)
* [`omniauthable`](https://github.com/plataformatec/devise/blob/master/lib/devise/models/omniauthable.rb)

You may not want all of these features enabled in your app. That's OK! You can mix and match to suit your own unique style.

The following example shows how to disable email confirmation.

##### Example: disable email confirmation

Just list the devise modules that you want to include **before** including the `DeviseTokenAuth::Concerns::User` model concern.

~~~ruby
# app/models/user.rb
class User < ActiveRecord::Base

  # notice this comes BEFORE the include statement below
  # also notice that :confirmable is not included in this block
  devise :database_authenticatable, :recoverable,
         :trackable, :validatable, :registerable,
         :omniauthable

  # note that this include statement comes AFTER the devise block above
  include DeviseTokenAuth::Concerns::User
end
~~~

Some features include routes that you may not want mounted to your app. The following example shows how to disable OAuth and its routes.

##### Example: disable OAuth authentication

First instruct the model not to include the `omniauthable` module.

~~~ruby
# app/models/user.rb
class User < ActiveRecord::Base

  # notice that :omniauthable is not included in this block
  devise :database_authenticatable, :confirmable,
         :recoverable, :trackable, :validatable,
         :registerable

  include DeviseTokenAuth::Concerns::User
end
~~~

Now tell the route helper to `skip` mounting the `omniauth_callbacks` controller:

~~~ruby
Rails.application.routes.draw do
  # config/routes.rb
  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks]
end
~~~
