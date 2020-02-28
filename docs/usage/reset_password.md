## Reset password flow

As a requirement you need to have `allow_password_change` field for any flow. There are 2 flows for reseting the password, one more web focused and other more mobile focused:

### Main reset password flow (use auth headers)

This is the overall workflow for a User to reset their password:

- user goes to a page on the front end site which contains a form with a single text field, they type their email address into this field and click a button to submit the form

- that form submission sends a request to the API: `POST /auth/password` with some parameters: `email` (the email supplied in the field) & `redirect_url` (a page in the front end site that will contain a form with `password` and `password_confirmation` fields)

- the API responds to this request by generating a `reset_password_token` and sending an email (the `reset_password_instructions.html.erb` file from devise) to the email address provided within the `email` parameter

  - we need to modify the `reset_password_instructions.html.erb` file to point to the API: `GET /auth/password/edit`
  - for example, if you have your API under the `api/v1` namespaces: `<%= link_to 'Change my password', edit_api_v1_user_password_url(reset_password_token: @token, config: message['client-config'].to_s, redirect_url: message['redirect-url'].to_s) %>` (I came up with this `link_to` by referring to [this line](https://github.com/lynndylanhurley/devise_token_auth/blob/15bf7857eca2d33602c7a9cb9d08db8a160f8ab8/app/views/devise/mailer/reset_password_instructions.html.erb#L5))

- the user clicks the link in the email, which brings them to the 'Verify user by password reset token' endpoint (`GET /password/edit`)

- this endpoint verifies the user and redirects them to the `redirect_url` (or the one you set in an initializer as default_password_reset_url) with the auth headers if they are who they claim to be (if their `reset_password_token` matches a User record)

- this `redirect_url` is a page on the frontend which contains a `password` and `password_confirmation` field

- the user submits the form on this frontend page, which sends a request to API: `PUT /auth/password` with the `password` and `password_confirmation` parameters. In addition headers need to be included from the url params (you get these from the url as query params). A side note, ensure that the header names follow the convention outlined in `config/initializers/devise_token_auth.rb`; at this time of writing it is: `uid`, `client` and `access-token`.

  - _Ensure that the `uid` sent in the headers is not URL-escaped. e.g. it should be bob@example.com, not bob%40example.com_

- the API changes the user's password and responds back with a success message

- the front end needs to manually redirect the user to its login page after receiving this success response

- the user logs in

The next diagram shows how it works:

![password reset flow](../password_diagram_reset.jpg)

If you get in any trouble configuring or overriding the behavior, you can check the [issue #604](https://github.com/lynndylanhurley/devise_token_auth/issues/604).

### Mobile alternative flow (use reset_password_token)

This flow is enabled with `require_client_password_reset_token` (by default is false), it is also useful for webs. This flow was done because the main one doesn't support deep linking (if you want to reset the password in the mobile app). It works like the main one but instead of receiving and sending the auth headers, you need to send the `reset_password_token`, but just in case, we can explain it step by step:

1. User fills out password reset request form (this POST `/auth/password`)
2. User is sent an email
3. User clicks confirmation link (this GET `/auth/password/edit`)
4. Link leads to the client to the `redirect_url` (instead of the API) with a `reset_password_token`
5. User submits password along with reset_password_token (this PUT `/auth/password`)
6. User is now authorized and has a new password
