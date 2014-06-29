require 'test_helper'
require 'generators/devise_token_auth/devise_token_auth_generator'

module DeviseTokenAuth
  class DeviseTokenAuthGeneratorTest < Rails::Generators::TestCase
    tests DeviseTokenAuthGenerator
    destination Rails.root.join('tmp/generators')
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
