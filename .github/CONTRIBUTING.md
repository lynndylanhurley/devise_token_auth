# Contribution Guidelines

## Suggest changes

1. Create a feature branch with your changes.
2. Please add a test for your change. Only refactoring and documentation changes require no new tests. If you are adding functionality or fixing a bug, we need a test!
3. Make all the tests pass against `ActiveRecord` and `Mongoid`.
4. Issue a Pull Request.

I will grant you commit access if you send quality pull requests.

## Run the tests

**Prepare** by installing and migrating the database:

1. Clone this repo
1. Run `bundle install`
1. Run `bundle exec rake db:migrate`
1. Run `RAILS_ENV=test bundle exec rake db:migrate`

Now your environment is ready to run tests.

To run the full **test suite** with the [guard](https://github.com/guard/guard) test runner:

```shell
bundle exec guard
```

Guard will re-run each test suite when changes are made to its corresponding files.

To run **just one test**: Flavio Castelli blogged about [how to execute a single unit test (or even a single test method)](https://flavio.castelli.me/2010/05/28/how-to-run-a-single-rails-unit-test/) instead of running the complete unit test suite.

To run the full **test suite** with the guard and the [appraisal](https://github.com/thoughtbot/appraisal) against `ActiveRecord`:

```shell
bundle exec appraisal rails-5-1 guard
# the same
DEVISE_TOKEN_AUTH_ORM=active_record DB=sqlite bundle exec appraisal
```

`DB` environment variable can take `sqlite`, `mysql`, and `postgresql` values.

against `Mongoid`:

```shell
DEVISE_TOKEN_AUTH_ORM=mongoid bundle exec appraisal rails-5-1-mongoid-7 guard
```
