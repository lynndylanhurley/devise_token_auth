1. Create a feature branch with your changes.
2. Write some test cases.
3. Make all the tests pass.
4. Issue a pull request.

I will grant you commit access if you send quality pull requests.

To run the test suite do the following:

1. Clone this repo
2. Run `bundle install`
3. Run `rake db:migrate`
4. Run `RAILS_ENV=test rake db:migrate`
5. Run `guard`

The last command will open the [guard](https://github.com/guard/guard) test-runner. Guard will re-run each test suite when changes are made to its corresponding files.

To run just one test:

1. Clone this repo
2. Run `bundle install`
3. Run `rake db:migrate`
4. Run `RAILS_ENV=test rake db:migrate`
5. See this link for various ways to run a single file or a single test: http://flavio.castelli.name/2010/05/28/rails_execute_single_test/

