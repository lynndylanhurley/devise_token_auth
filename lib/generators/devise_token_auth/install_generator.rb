module DeviseTokenAuth
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    argument :user_class, type: :string, default: "User"
    argument :mount_path, type: :string, default: 'auth'

    def create_initializer_file
      copy_file("devise_token_auth.rb", "config/initializers/devise_token_auth.rb")
    end

    def copy_migrations
      if self.class.migration_exists?("db/migrate", "devise_token_auth_create_#{ user_class.underscore }")
        say_status("skipped", "Migration 'devise_token_auth_create_#{ user_class.underscore }' already exists")
      else
        migration_template(
          "devise_token_auth_create_users.rb.erb",
          "db/migrate/devise_token_auth_create_#{ user_class.pluralize.underscore }.rb"
        )
      end
    end

    def create_user_model
      fname = "app/models/#{ user_class.underscore }.rb"
      unless File.exist?(File.join(destination_root, fname))
        template("user.rb", fname)
      else
        inclusion = "include DeviseTokenAuth::Concerns::User"
        unless parse_file_for_line(fname, inclusion)
          
          active_record_needle = (Rails::VERSION::MAJOR == 5) ? 'ApplicationRecord' : 'ActiveRecord::Base'
          inject_into_file fname, after: "class #{user_class} < #{active_record_needle}\n" do <<-'RUBY'
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User
          RUBY
          end
        end
      end
    end

    def include_controller_concerns
      fname = "app/controllers/application_controller.rb"
      line  = "include DeviseTokenAuth::Concerns::SetUserByToken"

      if File.exist?(File.join(destination_root, fname))
        if parse_file_for_line(fname, line)
          say_status("skipped", "Concern is already included in the application controller.")
        elsif is_rails_api?
          inject_into_file fname, after: "class ApplicationController < ActionController::API\n" do <<-'RUBY'
  include DeviseTokenAuth::Concerns::SetUserByToken
          RUBY
          end
        else
          inject_into_file fname, after: "class ApplicationController < ActionController::Base\n" do <<-'RUBY'
  include DeviseTokenAuth::Concerns::SetUserByToken
          RUBY
          end
        end
      else
        say_status("skipped", "app/controllers/application_controller.rb not found. Add 'include DeviseTokenAuth::Concerns::SetUserByToken' to any controllers that require authentication.")
      end
    end

    def add_route_mount
      f    = "config/routes.rb"
      str  = "mount_devise_token_auth_for '#{user_class}', at: '#{mount_path}'"

      if File.exist?(File.join(destination_root, f))
        line = parse_file_for_line(f, "mount_devise_token_auth_for")

        unless line
          line = "Rails.application.routes.draw do"
          existing_user_class = false
        else
          existing_user_class = true
        end

        if parse_file_for_line(f, str)
          say_status("skipped", "Routes already exist for #{user_class} at #{mount_path}")
        else
          insert_after_line(f, line, str)

          if existing_user_class
            scoped_routes = ""+
              "as :#{user_class.underscore} do\n"+
              "    # Define routes for #{user_class} within this block.\n"+
              "  end\n"
            insert_after_line(f, str, scoped_routes)
          end
        end
      else
        say_status("skipped", "config/routes.rb not found. Add \"mount_devise_token_auth_for '#{user_class}', at: '#{mount_path}'\" to your routes file.")
      end
    end

    private

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    def insert_after_line(filename, line, str)
      gsub_file filename, /(#{Regexp.escape(line)})/mi do |match|
        "#{match}\n  #{str}"
      end
    end

    def parse_file_for_line(filename, str)
      match = false

      File.open(File.join(destination_root, filename)) do |f|
        f.each_line do |line|
          if line =~ /(#{Regexp.escape(str)})/mi
            match = line
          end
        end
      end
      match
    end

    def is_rails_api?
      fname = "app/controllers/application_controller.rb"
      line = "class ApplicationController < ActionController::API"
      parse_file_for_line(fname, line)
    end

    def json_supported_database?
      (postgres? && postgres_correct_version?) || (mysql? && mysql_correct_version?)
    end

    def postgres?
      database_name == 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
    end

    def postgres_correct_version?
      database_version > '9.3'
    end

    def mysql?
      database_name == 'ActiveRecord::ConnectionAdapters::MysqlAdapter'
    end

    def mysql_correct_version?
      database_version > '5.7.7'
    end

    def database_name
      ActiveRecord::Base.connection.class.name
    end

    def database_version
      ActiveRecord::Base.connection.select_value('SELECT VERSION()')
    end
  end
end
