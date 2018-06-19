# Contribution Guidelines

## Suggest changes

1. Create a feature branch with your changes.
2. Please add a test for your change. Only refactoring and documentation changes
require no new tests. If you are adding functionality or fixing a bug, we need
a test!
3. Make all the tests pass.
4. Issue a Pull Request.

I will grant you commit access if you send quality pull requests.

## Run the tests

**Prepare** by installing and migrating the database:

1. Clone this repo
2. Run `bundle install`
3. Run `bundle exec rake db:migrate`
4. Run `RAILS_ENV=test bundle exec rake db:migrate`

Now your environment is ready to run tests.

5. To run the full **test suite** with the [guard](https://github.com/guard/guard) test runner:

```shell
bundle exec guard
```

Guard will re-run each test suite when changes are made to its corresponding files.

6. To run **just one test**: Flavio Castelli blogged about [how to execute a single unit test (or even a single test method)](https://flavio.castelli.me/2010/05/28/rails_execute_single_test/) instead of running the complete unit test suite.

7. We care about code coverage and use `SimpleCov` to analyze the code and generate
test coverage reports. It's possible to check the test coverage by running
`bundle exec rake coverage_report`. Please make sure to not decrease our `current % covered`.
