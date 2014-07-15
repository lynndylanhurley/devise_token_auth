module DeviseTokenAuth
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    argument :user_class, :type => :string, :default => "User"

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
      template("user.rb", "app/models/#{ user_class.underscore }.rb")
    end

    private

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end
  end
end
