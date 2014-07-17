require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DeviseTokenAuth::RegistrationsControllerTest < ActionController::TestCase
  describe DeviseTokenAuth::RegistrationsController do
    describe "Successful registration" do
      before do
        xhr :post, :create, {
          email: -> { Faker::Internet.email },
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: -> { Faker::Internet.url }
        }

        @user = assigns(:resource)
        @data = JSON.parse(response.body)
        @mail = ActionMailer::Base.deliveries.last
      end

      test "request should be successful" do
        assert_equal 200, response.status
      end

      test "user should have been created" do
        assert @user.id
      end

      test "user should not be confirmed" do
        assert_nil @user.confirmed_at
      end

      test "new user data should be returned as json" do
        assert @data['data']['email']
      end

      test "new user should receive confirmation email" do
        assert_equal @user.email, @mail['to'].to_s
      end

      test "new user password should not be returned" do
        assert_nil @data['data']['password']
      end
    end

    describe "Mismatched passwords" do
      before do
        xhr :post, :create, {
          email: -> { Faker::Internet.email },
          password: "secret123",
          password_confirmation: "bogus",
          confirm_success_url: -> { Faker::Internet.url }
        }

        @user = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test "request should not be successful" do
        assert_equal 403, response.status
      end

      test "user should have been created" do
        assert_nil @user.id
      end

      test "error should be returned in the response" do
        assert @data['errors'].length
      end
    end

    describe "Existing users" do
      before do
        @existing_user = users(:confirmed_email_user)

        xhr :post, :create, {
          email: @existing_user.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: -> { Faker::Internet.url }
        }

        @user = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test "request should not be successful" do
        assert_equal 403, response.status
      end

      test "user should have been created" do
        assert_nil @user.id
      end

      test "error should be returned in the response" do
        assert @data['errors'].length
      end
    end


    describe "Ouath user has existing email" do
      before do
        @existing_user = users(:duplicate_email_facebook_user)

        xhr :post, :create, {
          email: @existing_user.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: -> { Faker::Internet.url }
        }

        @user = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test "request should be successful" do
        assert_equal 200, response.status
      end

      test "user should have been created" do
        assert @user.id
      end

      test "new user data should be returned as json" do
        assert @data['data']['email']
      end
    end

    describe "Alternate user class" do
      setup do
        @request.env['devise.mapping'] = Devise.mappings[:mang]
      end

      teardown do
        @request.env['devise.mapping'] = Devise.mappings[:user]
      end

      before do
        xhr :post, :create, {
          email: -> { Faker::Internet.email },
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: -> { Faker::Internet.url }
        }

        @user = assigns(:resource)
        @data = JSON.parse(response.body)
        @mail = ActionMailer::Base.deliveries.last
      end

      test "request should be successful" do
        assert_equal 200, response.status
      end

      test "use should be a Mang" do
        assert_equal "Mang", @user.class.name
      end
    end
  end
end
