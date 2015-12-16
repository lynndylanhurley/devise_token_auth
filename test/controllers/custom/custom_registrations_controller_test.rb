require 'test_helper'

class Custom::RegistrationsControllerTest < ActionDispatch::IntegrationTest

  describe Custom::RegistrationsController do

    setup do
      @create_params = {
        email: Faker::Internet.email,
        password: "secret123",
        password_confirmation: "secret123",
        confirm_success_url: Faker::Internet.url,
        unpermitted_param: '(x_x)'
      }

      @create_without_password_confirmation = {
        email: Faker::Internet.email,
        password: "secret123",
        confirm_success_url: Faker::Internet.url,
        unpermitted_param: '(x_x)'
      }

      @existing_user = nice_users(:confirmed_email_user)
      @auth_headers  = @existing_user.create_new_auth_token
      @client_id     = @auth_headers['client']

      # ensure request is not treated as batch request
      age_token(@existing_user, @client_id)
    end

    test "yield resource to block on create success" do
      post '/nice_user_auth', @create_params
      assert @controller.create_block_called?, "create failed to yield resource to provided block"
    end

    test "do not yield resource to block on create failure" do
      post '/nice_user_auth', @create_without_password_confirmation
      assert_not @controller.create_block_called?, "create should not yield resource to provided block"
    end

    test "yield resource to block on create success with custom json" do
      post '/nice_user_auth', @create_params

      @data = JSON.parse(response.body)

      assert @controller.create_block_called?, "create failed to yield resource to provided block"
      assert_equal @data["custom"], "foo"
    end

    test "yield resource to block on update success" do
      put '/nice_user_auth', {
        nickname: "Ol' Sunshine-face",
      }, @auth_headers
      assert @controller.update_block_called?, "update failed to yield resource to provided block"
    end

    test "do not yield resource to block on update error" do
      put '/nice_user_auth', {
        password: "newpass123",
      }, @auth_headers
      assert_not @controller.update_block_called?, "update yield resource to provided"
    end

    test "yield resource to block on destroy success" do
      delete '/nice_user_auth', @auth_headers
      assert @controller.destroy_block_called?, "destroy failed to yield resource to provided block"
    end

  end

end
