# frozen_string_literal: true

source 'https://rubygems.org'

# Declare your gem's dependencies in devise_token_auth.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

group :development, :test do
  gem 'attr_encrypted'
  gem 'figaro', git: 'https://github.com/laserlemon/figaro'
  gem 'omniauth-facebook', git: 'https://github.com/mkdynamic/omniauth-facebook'
  gem 'omniauth-github',        git: 'https://github.com/intridea/omniauth-github'
  gem 'omniauth-google-oauth2', git: 'https://github.com/zquestz/omniauth-google-oauth2'
  gem 'rack-cors', require: 'rack/cors'
  gem 'sqlite3', '~> 1.3.6'
  gem 'thor'

  # testing
  # gem 'spring'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'fuzz_ball'
  gem 'guard'
  gem 'guard-minitest'
  gem 'minitest'
  gem 'minitest-focus'
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'mocha', '>= 1.5'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-remote'

  gem 'rubocop', require: false
end

# code coverage, metrics
group :test do
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
end

group :development do
  gem 'github_changelog_generator'
end

if ENV['MONGOID_VERSION']
  case ENV['MONGOID_VERSION']
  when /^7/
    gem 'mongoid', '~> 7'
  when /^6/
    gem 'mongoid', '~> 6'
  when /^5/
    gem 'mongoid', '~> 5'
  else
    gem 'mongoid', '>= 5'
  end
  
  gem 'mongoid-locker', '~> 1.0'
end
