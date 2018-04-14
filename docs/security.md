# Security

This gem takes the following steps to ensure security.

This gem uses auth tokens that are:
* [changed after every request](/docs/conceptual.md#about-token-management) (can be [turned off](https://github.com/lynndylanhurley/devise_token_auth/#initializer-settings)),
* [of cryptographic strength](https://ruby-doc.org/stdlib-2.1.0/libdoc/securerandom/rdoc/SecureRandom.html),
* hashed using [BCrypt](https://github.com/codahale/bcrypt-ruby) (not stored in plain-text),
* securely compared (to protect against timing attacks),
* invalidated after 2 weeks (thus requiring users to login again)

These measures were inspired by [this stackoverflow post](https://stackoverflow.com/questions/18605294/is-devises-token-authenticatable-secure).

This gem further mitigates timing attacks by using [this technique](https://gist.github.com/josevalim/fb706b1e933ef01e4fb6).

But the most important step is to use HTTPS. You are on the hook for that.
