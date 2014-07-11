class DeviseTokenAuthGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  desc "This generator creates an initializer file at config/initializers/devise_token_auth.rb"
  def create_initializer_file
    copy_file "devise_token_auth.rb", "config/initializers/devise_token_auth.rb"
  end
end
