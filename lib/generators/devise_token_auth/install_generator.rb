module DeviseTokenAuth
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    desc "This generator creates an initializer file at config/initializers/devise_token_auth.rb"
    def create_initializer_file
      copy_file("devise_token_auth.rb", "config/initializers/devise_token_auth.rb")
    end

    desc "This generator creates a user migration file at db/migrate/<%= migration_id %>_devise_token_auth_create_users.rb"
    def copy_migrations
      if self.class.migration_exists?("db/migrate", "devise_token_auth_create_users")
        say_status("skipped", "Migration 'devise_token_auth' already exists")
      else
        migration_template("devise_token_auth_create_users.rb", "db/migrate/devise_token_auth_create_users.rb")
      end
    end

    private

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end
  end
end
