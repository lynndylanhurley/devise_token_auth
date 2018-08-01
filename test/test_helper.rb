# frozen_string_literal: true

require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start 'rails' do
  add_filter ['.bundle', 'test', 'config']
end

ENV['RAILS_ENV'] = 'test'

require File.expand_path('dummy/config/environment', __dir__)
require 'rails/test_help'
require 'minitest/rails'
require 'mocha/minitest'

FactoryBot.definition_file_paths = [File.expand_path('factories', __dir__)]
FactoryBot.find_definitions

Dir[File.join(__dir__, 'support/**', '*.rb')].each { |file| require file }

# I hate the default reporter. Use ProgressReporter instead.
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

class ActionDispatch::IntegrationTest
  def follow_all_redirects!
    follow_redirect! while response.status.to_s =~ /^3\d{2}/
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  ActiveRecord::Migration.check_pending!

  # Add more helper methods to be used by all tests here...

  def age_token(user, client_id)
    if user.tokens[client_id]
      user.tokens[client_id]['updated_at'] = Time.zone.now - (DeviseTokenAuth.batch_request_buffer_throttle + 10.seconds)
      user.save!
    end
  end

  def expire_token(user, client_id)
    if user.tokens[client_id]
      user.tokens[client_id]['expiry'] = (Time.zone.now - (DeviseTokenAuth.token_lifespan.to_f + 10.seconds)).to_i
      user.save!
    end
  end

  # Suppress OmniAuth logger output
  def silence_omniauth
    previous_logger = OmniAuth.config.logger
    OmniAuth.config.logger = Logger.new('/dev/null')
    yield
  ensure
    OmniAuth.config.logger = previous_logger
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @routes = Dummy::Application.routes
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
end

# TODO: remove it when support for Rails < 5 has been dropped
module Rails
  module Controller
    module Testing
      module Integration
        %w[get post patch put head delete get_via_redirect post_via_redirect].each do |method|
          define_method(method) do |path_or_action, **args|
            if Rails::VERSION::MAJOR >= 5
              super path_or_action, args
            else
              super path_or_action, args[:params], args[:headers]
            end
          end
        end
      end
    end
  end
end

module ActionController
  class TestCase
    include Rails::Controller::Testing::Integration
  end
end
