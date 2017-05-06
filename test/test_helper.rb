require 'simplecov'

#SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  #SimpleCov::Formatter::HTMLFormatter,
  #CodeClimate::TestReporter::Formatter
#]

SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "rails/mongoid"
Mongoid.load!(Rails.root.join("config", "mongoid.yml"))
Mongo::Logger.logger.level = ::Logger::FATAL

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
require "minitest/pride"

ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
ActionDispatch::IntegrationTest.fixture_path = File.expand_path("../fixtures", __FILE__)

# I hate the default reporter. Use ProgressReporter instead.
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  ActiveRecord::Migration.check_pending!

  # Clean mongodb
  Mongoid.purge!
  # Register factories that it used for mongoid object
  FactoryGirl.definition_file_paths = [File.expand_path('../factories', __FILE__)]
  FactoryGirl.find_definitions

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def age_token(user, client_id)
    if user.tokens[client_id]
      user.tokens[client_id]['updated_at'] = Time.now - (DeviseTokenAuth.batch_request_buffer_throttle + 10.seconds)
      user.save!
    end
  end

  def expire_token(user, client_id)
    if user.tokens[client_id]
      user.tokens[client_id]['expiry'] = (Time.now - (DeviseTokenAuth.token_lifespan.to_f + 10.seconds)).to_i
      user.save!
    end
  end

  def get_confirmed_email_user_obj(test_mongoid)
    if test_mongoid
      create(:mongoid_user)
    else
      users(:confirmed_email_user)
    end
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @routes = Dummy::Application.routes
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
end
