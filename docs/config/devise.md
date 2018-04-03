## Customizing Devise Verbiage

Devise Token Auth ships with intelligent default wording for everything you need. But that doesn't mean you can't make it more awesome. You can override the [devise defaults](https://github.com/plataformatec/devise/blob/master/config/locales/en.yml) by creating a YAML file at `config/locales/devise.en.yml` and assigning whatever custom values you want. For example, to customize the subject line of your devise e-mails, you could do this:

~~~yaml
en:
  devise:
    mailer:
      confirmation_instructions:
        subject: "Please confirm your e-mail address"
      reset_password_instructions:
        subject: "Reset password request"
~~~
