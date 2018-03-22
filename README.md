# Devise Token Auth

[![Gem Version](https://badge.fury.io/rb/devise_token_auth.svg)](http://badge.fury.io/rb/devise_token_auth)
[![Build Status](https://travis-ci.org/lynndylanhurley/devise_token_auth.svg?branch=master)](https://travis-ci.org/lynndylanhurley/devise_token_auth)
[![Code Climate](https://codeclimate.com/github/lynndylanhurley/devise_token_auth/badges/gpa.svg)](https://codeclimate.com/github/lynndylanhurley/devise_token_auth)
[![Test Coverage](https://codeclimate.com/github/lynndylanhurley/devise_token_auth/badges/coverage.svg)](https://codeclimate.com/github/lynndylanhurley/devise_token_auth/coverage)
[![Dependency Status](https://gemnasium.com/lynndylanhurley/devise_token_auth.svg)](https://gemnasium.com/lynndylanhurley/devise_token_auth)
[![Downloads](https://img.shields.io/gem/dt/devise_token_auth.svg)](https://rubygems.org/gems/devise_token_auth)
[![Backers on Open Collective](https://opencollective.com/devise_token_auth/backers/badge.svg)](#backers)
[![Sponsors on Open Collective](https://opencollective.com/devise_token_auth/sponsors/badge.svg)](#sponsors)
[![Join the chat at https://gitter.im/lynndylanhurley/devise_token_auth](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/lynndylanhurley/devise_token_auth?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Simple, secure token-based authentication for Rails. This gem provides the following features:

* Seamless integration with:
  * [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) for [AngularJS](https://github.com/angular/angular.js)
  * [Angular2-Token](https://github.com/neroniaky/angular2-token) for [Angular2](https://github.com/angular/angular)
  * [redux-token-auth](https://github.com/kylecorbelli/redux-token-auth) for [React with Redux](https://github.com/reactjs/react-redux)
  * [jToker](https://github.com/lynndylanhurley/j-toker) for [jQuery](https://jquery.com/)
* Oauth2 authentication using [OmniAuth](https://github.com/intridea/omniauth).
* Email authentication using [Devise](https://github.com/plataformatec/devise), including:
  * User registration, update and deletion
  * Login and logout
  * Password reset, account confirmation
* Support for [multiple user models](./docs/usage/multiple_models.md).
* It is [secure](./docs/security.md).

This project leverages the following gems:

* [Devise](https://github.com/plataformatec/devise)
* [OmniAuth](https://github.com/intridea/omniauth)

## Installation

Add the following to your `Gemfile`:

~~~ruby
gem 'devise_token_auth'
~~~

Then install the gem using bundle:

~~~bash
bundle install
~~~

## [Docs](./docs)

## Need help?

Please use [StackOverflow](https://stackoverflow.com/questions/tagged/devise-token-auth) for help requests and how-to questions.

Please open GitHub issues for bugs and enhancements only, not general help requests. Please search previous issues (and Google and StackOverflow) before creating a new issue.

Please read the [issue reporting guidelines](#issue-reporting) before posting issues.

## [FAQ](./docs/faq)

## Contributors wanted!

See our [Contribution Guidelines](https://github.com/lynndylanhurley/devise_token_auth/blob/master/.github/CONTRIBUTING.md). Feel free to submit pull requests, review pull requests, or review open issues. If you'd like to get in contact, [Zach Feldman](https://github.com/zachfeldman) has been wrangling this effort, you can reach him with his name @gmail. Further discussion of this in [this issue](https://github.com/lynndylanhurley/devise_token_auth/issues/969).

## Live Demos

[Here is a demo](http://ng-token-auth-demo.herokuapp.com/) of this app running with the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module and [AngularJS](https://github.com/angular/angular.js).

[Here is a demo](https://angular2-token.herokuapp.com) of this app running with the [Angular2-Token](https://github.com/neroniaky/angular2-token) service and [Angular2](https://github.com/angular/angular).

[Here is a demo](https://j-toker-demo.herokuapp.com/) of this app using the [jToker](https://github.com/lynndylanhurley/j-toker) plugin and [React](http://facebook.github.io/react/).

The fully configured api used in these demos can be found [here](https://github.com/lynndylanhurley/devise_token_auth_demo).


## Callouts

Thanks to the following contributors:

* [@booleanbetrayal](https://github.com/booleanbetrayal)
* [@zachfeldman](https://github.com/zachfeldman)
* [@MaicolBen](https://github.com/MaicolBen)
* [@guilhermesimoes](https://github.com/guilhermesimoes)
* [@jasonswett](https://github.com/jasonswett)
* [@m2omou](https://github.com/m2omou)
* [@smarquez1](https://github.com/smarquez1)
* [@jartek](https://github.com/jartek)
* [@nicolas-besnard](https://github.com/nicolas-besnard)
* [@tbloncar](https://github.com/tbloncar)
* [@nickL](https://github.com/nickL)
* [@mchavarriagam](https://github.com/mchavarriagam)

<a href="graphs/contributors"><img src="https://opencollective.com/devise_token_auth/contributors.svg?width=890&button=false" /></a>

## Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/devise_token_auth#backer)]

[![](https://opencollective.com/devise_token_auth/backers.svg?width=890)](https://opencollective.com/devise_token_auth#backers)


## Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/devise_token_auth#sponsor)]

[![](https://opencollective.com/devise_token_auth/sponsor/0/avatar.svg)](https://opencollective.com/devise_token_auth/sponsor/0/website) [![](https://opencollective.com/devise_token_auth/sponsor/1/avatar.svg)](https://opencollective.com/devise_token_auth/sponsor/1/website) [![](https://opencollective.com/devise_token_auth/sponsor/2/avatar.svg)](https://opencollective.com/devise_token_auth/sponsor/2/website) [![](https://opencollective.com/devise_token_auth/sponsor/3/avatar.svg)](https://opencollective.com/devise_token_auth/sponsor/3/website) [![](https://opencollective.com/devise_token_auth/sponsor/4/avatar.svg)](https://opencollective.com/devise_token_auth/sponsor/4/website) [![](https://opencollective.com/devise_token_auth/sponsor/5/avatar.svg)](https://opencollective.com/devise_token_auth/sponsor/5/website) [![](https://opencollective.com/devise_token_auth/sponsor/6/avatar.svg)](https://opencollective.com/devise_token_auth/sponsor/6/website) [![](https://opencollective.com/devise_token_auth/sponsor/7/avatar.svg)](https://opencollective.com/devise_token_auth/sponsor/7/website) [![](https://opencollective.com/devise_token_auth/sponsor/8/avatar.svg)](https://opencollective.com/devise_token_auth/sponsor/8/website) [![](https://opencollective.com/devise_token_auth/sponsor/9/avatar.svg)](https://opencollective.com/devise_token_auth/sponsor/9/website)

## License
This project uses the WTFPL
