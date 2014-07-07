ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
require "minitest/pride"

ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__) 

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  include Devise::TestHelpers

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  setup do
    @routes = DeviseTokenAuth::Engine.routes
  end

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
end
