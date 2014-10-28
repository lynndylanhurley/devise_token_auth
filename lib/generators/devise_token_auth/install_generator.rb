module DeviseTokenAuth
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    argument :user_class, type: :string, default: "User"
    argument :mount_path, type: :string, default: '/auth'

    def create_initializer_file
      copy_file("devise_token_auth.rb", "config/initializers/devise_token_auth.rb")
    end

    def copy_migrations
      if self.class.migration_exists?("db/migrate", "devise_token_auth_create_#{ user_class.underscore }")
        say_status("skipped", "Migration 'devise_token_auth_create_#{ user_class.underscore }' already exists")
      else
        if model_exists?(user_class)
        migration_template(
          "add_devise_token_auth_to_users.rb.erb",
          "db/migrate/add_devise_token_auth_to_#{ user_class.pluralize.underscore }.rb"
        )
        else 
         migration_template(
          "devise_token_auth_create_users.rb.erb",
          "db/migrate/devise_token_auth_create_#{ user_class.pluralize.underscore }.rb"
        ) 
        end
      end
    end

    def create_user_model
      fname = "app/models/#{ user_class.underscore }.rb"
      unless File.exist?(File.join(destination_root, fname))
        template("user.rb", fname)
      else
        inclusion = "include DeviseTokenAuth::Concerns::User"
        unless parse_file_for_line(fname, inclusion)
          inject_into_file fname, after: "class #{user_class} < ActiveRecord::Base\n" do <<-'RUBY'
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

    def migration_data
<<RUBY
      ## Database authenticatable
      t.string :email
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0, :null => false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## User Info
      t.string :name
      t.string :nickname
      t.string :image

      ## unique oauth id
      t.string :provider
      t.string :uid, :null => false, :default => ""

      ## Tokens
      t.text :tokens

RUBY
    end

    private

    def model_exists?(model)
      model_path = "app/models/#{ model.underscore }.rb"
      File.exist?(File.join(destination_root, model_path))
    end
    
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
  end
end
