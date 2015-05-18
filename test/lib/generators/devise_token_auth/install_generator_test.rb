require 'test_helper'
require 'fileutils'
require 'generators/devise_token_auth/install_generator'

module DeviseTokenAuth
  class InstallGeneratorTest < Rails::Generators::TestCase
    tests InstallGenerator
    destination Rails.root.join('tmp/generators')

    describe 'default values, clean install' do
      setup :prepare_destination

      before do
        run_generator
      end

      test 'user model is created, concern is included' do
        assert_file 'app/models/user.rb' do |model|
          assert_match(/include DeviseTokenAuth::Concerns::User/, model)
        end
      end

      test 'initializer is created' do
        assert_file 'config/initializers/devise_token_auth.rb'
      end

      test 'migration is created' do
        assert_migration 'db/migrate/devise_token_auth_create_users.rb'
      end

      test 'subsequent runs raise no errors' do
        run_generator
      end
    end

    describe 'existing user model' do
      setup :prepare_destination

      before do
        @dir = File.join(destination_root, "app", "models")

        @fname = File.join(@dir, "user.rb")

        # make dir if not exists
        FileUtils.mkdir_p(@dir)

        @f = File.open(@fname, 'w') {|f|
          f.write <<-RUBY
class User < ActiveRecord::Base

  def whatever
    puts 'whatever'
  end
end
          RUBY
        }

        run_generator
      end

      test 'user concern is injected into existing model' do
        assert_file 'app/models/user.rb' do |model|
          assert_match(/include DeviseTokenAuth::Concerns::User/, model)
        end
      end

      test 'subsequent runs do not modify file' do
        run_generator
        assert_file 'app/models/user.rb' do |model|
          matches = model.scan(/include DeviseTokenAuth::Concerns::User/m).size
          assert_equal 1, matches
        end
      end
    end


    describe 'routes' do
      setup :prepare_destination

      before do
        @dir = File.join(destination_root, "config")

        @fname = File.join(@dir, "routes.rb")

        # make dir if not exists
        FileUtils.mkdir_p(@dir)

        @f = File.open(@fname, 'w') {|f|
          f.write <<-RUBY
Rails.application.routes.draw do
  patch '/chong', to: 'bong#index'
end
          RUBY
        }

        run_generator
      end

      test 'route method is appended to routes file' do
        assert_file 'config/routes.rb' do |routes|
          assert_match(/mount_devise_token_auth_for 'User', at: 'auth'/, routes)
        end
      end

      test 'subsequent runs do not modify file' do
        run_generator
        assert_file 'config/routes.rb' do |routes|
          matches = routes.scan(/mount_devise_token_auth_for 'User', at: 'auth'/m).size
          assert_equal 1, matches
        end
      end

      describe 'subsequent models' do
        before do
          run_generator %w(Mang mangs)
        end

        test 'migration is created' do
          assert_migration 'db/migrate/devise_token_auth_create_mangs.rb'
        end

        test 'route method is appended to routes file' do
          assert_file 'config/routes.rb' do |routes|
            assert_match(/mount_devise_token_auth_for 'Mang', at: 'mangs'/, routes)
          end
        end

        test 'devise_for block is appended to routes file' do
          assert_file 'config/routes.rb' do |routes|
            assert_match(/as :mang do/, routes)
            assert_match(/# Define routes for Mang within this block./, routes)
          end
        end
      end
    end

    describe 'application controller' do
      setup :prepare_destination

      before do
        @dir = File.join(destination_root, "app", "controllers")

        @fname = File.join(@dir, "application_controller.rb")

        # make dir if not exists
        FileUtils.mkdir_p(@dir)

        @f = File.open(@fname, 'w') {|f|
          f.write <<-RUBY
class ApplicationController < ActionController::Base
  def whatever
    'whatever'
  end
end
          RUBY
        }

        run_generator
      end

      test 'controller concern is appended to application controller' do
        assert_file 'app/controllers/application_controller.rb' do |controller|
          assert_match(/include DeviseTokenAuth::Concerns::SetUserByToken/, controller)
        end
      end

      test 'subsequent runs do not modify file' do
        run_generator
        assert_file 'app/controllers/application_controller.rb' do |controller|
          matches = controller.scan(/include DeviseTokenAuth::Concerns::SetUserByToken/m).size
          assert_equal 1, matches
        end
      end
    end
  end
end
