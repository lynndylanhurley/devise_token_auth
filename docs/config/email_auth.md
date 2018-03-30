## Email authentication
If you wish to use email authentication, you must configure your Rails application to send email. [Read here](http://guides.rubyonrails.org/action_mailer_basics.html) for more information.

I recommend using [mailcatcher](https://mailcatcher.me/) for development.

##### mailcatcher development example configuration:
~~~ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_mailer.default_url_options = { host: 'your-dev-host.dev' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'your-dev-host.dev', port: 1025 }
end
~~~

If you wish to send custom e-mails instead of using the default devise templates, you can [do that too](/docs/usage/overrides.md#email-template-overrides).
