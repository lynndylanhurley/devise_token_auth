## Configuration TL;DR

You will need to create a [user model](/docs/usage/model_concerns.md), [define routes](/docs/usage/routes.md), [include concerns](/docs/usage/controller_methods.md), and you may want to alter some of the [default settings](initialization.md) for this gem. Run the following command for an easy one-step installation:

~~~bash
rails g devise_token_auth:install [USER_CLASS] [MOUNT_PATH]
~~~

**Example**:

~~~bash
rails g devise_token_auth:install User auth
~~~

This generator accepts the following optional arguments:

| Argument | Default | Description |
|---|---|---|
| USER_CLASS | `User` | The name of the class to use for user authentication. |
| MOUNT_PATH | `auth` | The path at which to mount the authentication routes. [Read more](#usage-tldr). |

The following events will take place when using the install generator:

* An initializer will be created at `config/initializers/devise_token_auth.rb`. [Read more](initialization.md).

* A model will be created in the `app/models` directory. If the model already exists, a concern will be included at the top of the file. [Read more](/docs/usage/model_concerns.md).

* Routes will be appended to file at `config/routes.rb`. [Read more](/docs/usage/routes.md).

* A concern will be included by your application controller at `app/controllers/application_controller.rb`. [Read more](/docs/usage/controller_methods.md).

* A migration file will be created in the `db/migrate` directory. Inspect the migrations file, add additional columns if necessary, and then run the migration:

  ~~~bash
  rake db:migrate
  ~~~

You may also need to configure the following items:

* **OmniAuth providers** when using 3rd party oauth2 authentication. [Read more](omniauth.md).
* **Cross Origin Request Settings** when using cross-domain clients. [Read more](cors.md).
* **Email** when using email registration. [Read more](email_auth.md).
* **Multiple model support** may require additional steps. [Read more](/docs/usage/multiple_models.md).
