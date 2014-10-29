require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DeviseTokenAuth::SessionsControllerTest < ActionController::TestCase
  describe DeviseTokenAuth::SessionsController do
    describe "Confirmed user" do
      before do
        @existing_user = users(:confirmed_email_user)
        @existing_user.skip_confirmation!
        @existing_user.save!
      end

      describe 'success' do
        before do
          xhr :post, :create, {
            email: @existing_user.email,
            password: 'secret123'
          }

          @resource = assigns(:resource)
          @data = JSON.parse(response.body)
        end

        test "request should succeed" do
          assert_equal 200, response.status
        end

        test "request should return user data" do
          assert_equal @existing_user.email, @data['data']['email']
        end
      end

      describe 'authed user sign out' do
        before do
          @auth_headers = @existing_user.create_new_auth_token
          request.headers.merge!(@auth_headers)
          xhr :delete, :destroy, format: :json
        end

        test "user is successfully logged out" do
          assert_equal 200, response.status
        end

        test "token was destroyed" do
          @existing_user.reload
          refute @existing_user.tokens[@auth_headers["client"]]
        end
      end

      describe 'unauthed user sign out' do
        before do
          @auth_headers = @existing_user.create_new_auth_token
          xhr :delete, :destroy, format: :json
        end

        test "unauthed request returns 404" do
          assert_equal 404, response.status
        end
      end

      describe 'failure' do
        before do
          xhr :post, :create, {
            email: @existing_user.email,
            password: 'bogus'
          }

          @resource = assigns(:resource)
          @data = JSON.parse(response.body)
        end

        test "request should fail" do
          assert_equal 401, response.status
        end

        test "response should contain errors" do
          assert @data['errors']
        end
      end
    end

    describe "Unconfirmed user" do
      before do
        @unconfirmed_user = users(:unconfirmed_email_user)
        xhr :post, :create, {
          email: @unconfirmed_user.email,
          password: 'secret123'
        }
        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test "request should fail" do
        assert_equal 401, response.status
      end

      test "response should contain errors" do
        assert @data['errors']
      end
    end

    describe "Non-existing user" do
      before do
        xhr :post, :create, {
          email: -> { Faker::Internet.email },
          password: -> { Faker::Number.number(10) }
        }
        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test "request should fail" do
        assert_equal 401, response.status
      end

      test "response should contain errors" do
        assert @data['errors']
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
        @existing_user = mangs(:confirmed_email_user)
        @existing_user.skip_confirmation!
        @existing_user.save!

        xhr :post, :create, {
          email: @existing_user.email,
          password: 'secret123'
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test "request should succeed" do
        assert_equal 200, response.status
      end

      test "request should return user data" do
        assert_equal @existing_user.email, @data['data']['email']
      end
    end
  end
end
