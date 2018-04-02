## Using multiple models

### View Live Multi-User Demos

* [AngularJS](https://ng-token-auth-demo.herokuapp.com/multi-user)
* [Angular2](https://angular2-token.herokuapp.com)
* [React + jToker](https://j-toker-demo.herokuapp.com/#/alt-user)

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
    mount_devise_token_auth_for 'User', at: 'auth'

    # define :admins as the second devise mapping. routes using this class will
    # need to be defined within a devise_scope as shown below
    mount_devise_token_auth_for "Admin", at: 'admin_auth'

    # this route will authorize requests using the User class
    get 'demo/members_only', to: 'demo#members_only'

    # routes within this block will authorize requests using the Admin class
    devise_scope :admin do
      get 'demo/admins_only', to: 'demo#admins_only'
    end
  end
  ~~~

1. Configure any `Admin` restricted controllers. Controllers will now have access to the methods [described here](#methods):
  * `before_action :authenticate_admin!`
  * `current_admin`
  * `admin_signed_in?`


### Group access

It is also possible to control access to multiple user types at the same time using groups. The following example shows how to limit controller access to both `User` and `Admin` users.

##### Example: group authentication

~~~ruby
class DemoGroupController < ApplicationController
  devise_token_auth_group :member, contains: [:user, :admin]
  before_action :authenticate_member!

  def members_only
    render json: {
      data: {
        message: "Welcome #{current_member.name}",
        user: current_member
      }
    }, status: 200
  end
end
~~~

In the above example, the following methods will be available (in addition to `current_user`, `current_admin`, etc.):

  * `before_action: :authenticate_member!`
  * `current_member`
  * `member_signed_in?`
