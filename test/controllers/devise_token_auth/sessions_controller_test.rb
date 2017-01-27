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
          @old_sign_in_count      = @existing_user.sign_in_count
          @old_current_sign_in_at = @existing_user.current_sign_in_at
          @old_last_sign_in_at    = @existing_user.last_sign_in_at
          @old_sign_in_ip         = @existing_user.current_sign_in_ip
          @old_last_sign_in_ip    = @existing_user.last_sign_in_ip

          xhr :post, :create, {
            email: @existing_user.email,
            password: 'secret123'
          }

          @resource = assigns(:resource)
          @data = JSON.parse(response.body)

          @new_sign_in_count      = @resource.sign_in_count
          @new_current_sign_in_at = @resource.current_sign_in_at
          @new_last_sign_in_at    = @resource.last_sign_in_at
          @new_sign_in_ip         = @resource.current_sign_in_ip
          @new_last_sign_in_ip    = @resource.last_sign_in_ip
        end

        test "request should succeed" do
          assert_equal 200, response.status
        end

        test "request should return user data" do
          assert_equal @existing_user.email, @data['data']['email']
        end

        describe 'trackable' do
          test 'sign_in_count incrementns' do
            assert_equal @old_sign_in_count + 1, @new_sign_in_count
          end

          test 'current_sign_in_at is updated' do
            refute @old_current_sign_in_at
            assert @new_current_sign_in_at
          end

          test 'last_sign_in_at is updated' do
            refute @old_last_sign_in_at
            assert @new_last_sign_in_at
          end

          test 'sign_in_ip is updated' do
            refute @old_sign_in_ip
            assert_equal "0.0.0.0", @new_sign_in_ip
          end

          test 'last_sign_in_ip is updated' do
            refute @old_last_sign_in_ip
            assert_equal "0.0.0.0", @new_last_sign_in_ip
          end
        end
      end

      describe 'get sign_in is not supported' do
        before do
          xhr :get, :new, {
            nickname: @existing_user.nickname,
            password: 'secret123'
          }
          @data = JSON.parse(response.body)
        end

        test 'user is notified that they should use post sign_in to authenticate' do
          assert_equal 405, response.status
        end
        test "response should contain errors" do
          assert @data['errors']
          assert_equal @data['errors'], [I18n.t("devise_token_auth.sessions.not_supported")]
        end
      end

      describe 'header sign_in is supported' do
        before do
          request.headers.merge!(
            'email' => @existing_user.email,
            'password' => 'secret123')

          xhr :head, :create
          @data = JSON.parse(response.body)
        end

        test 'user can sign in using header request' do
          assert_equal 200, response.status
        end
      end

      describe 'alt auth keys' do
        before do
          xhr :post, :create, {
            nickname: @existing_user.nickname,
            password: 'secret123'
          }
          @data = JSON.parse(response.body)
        end

        test 'user can sign in using nickname' do
          assert_equal 200, response.status
          assert_equal @existing_user.email, @data['data']['email']
        end
      end

      describe 'authed user sign out' do
        before do
          def @controller.reset_session_called; @reset_session_called == true; end
          def @controller.reset_session; @reset_session_called = true; end
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

        test "session was destroyed" do
          assert_equal true, @controller.reset_session_called
        end
      end

      describe 'unauthed user sign out' do
        before do
          @auth_headers = @existing_user.create_new_auth_token
          xhr :delete, :destroy, format: :json
          @data = JSON.parse(response.body)
        end

        test "unauthed request returns 404" do
          assert_equal 404, response.status
        end

        test "response should contain errors" do
          assert @data['errors']
          assert_equal @data['errors'], [I18n.t("devise_token_auth.sessions.user_not_found")]
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
          assert_equal @data['errors'], [I18n.t("devise_token_auth.sessions.bad_credentials")]
        end
      end

      describe 'failure with bad password when change_headers_on_each_request false' do
        before do
          DeviseTokenAuth.change_headers_on_each_request = false

          # accessing current_user calls through set_user_by_token,
          # which initializes client_id
          @controller.current_user

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
          assert_equal @data['errors'], [I18n.t("devise_token_auth.sessions.bad_credentials")]
        end

        after do
            DeviseTokenAuth.change_headers_on_each_request = true
        end
      end

      describe 'case-insensitive email' do

        before do
          @resource_class = User
          @request_params = {
            email: @existing_user.email.upcase,
            password: 'secret123'
          }
        end

        test "request should succeed if configured" do
          @resource_class.case_insensitive_keys = [:email]
          xhr :post, :create, @request_params
          assert_equal 200, response.status
        end

        test "request should fail if not configured" do
          @resource_class.case_insensitive_keys = []
          xhr :post, :create, @request_params
          assert_equal 401, response.status
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
        assert_equal @data['errors'], [I18n.t("devise_token_auth.sessions.not_confirmed", email: @unconfirmed_user.email)]
      end
    end

    describe "Unconfirmed user with allowed unconfirmed access" do
      before do
        @original_duration = Devise.allow_unconfirmed_access_for
        Devise.allow_unconfirmed_access_for = 3.days
        @recent_unconfirmed_user = users(:recent_unconfirmed_email_user)
        xhr :post, :create, {
          email: @recent_unconfirmed_user.email,
          password: 'secret123'
        }
        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      after do
        Devise.allow_unconfirmed_access_for = @original_duration
      end

      test "request should succeed" do
        assert_equal 200, response.status
      end

      test "request should return user data" do
        assert_equal @recent_unconfirmed_user.email, @data['data']['email']
      end
    end

    describe "Unconfirmed user with expired unconfirmed access" do
      before do
        @original_duration = Devise.allow_unconfirmed_access_for
        Devise.allow_unconfirmed_access_for = 3.days
        @unconfirmed_user = users(:unconfirmed_email_user)
        xhr :post, :create, {
          email: @unconfirmed_user.email,
          password: 'secret123'
        }
        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      after do
        Devise.allow_unconfirmed_access_for = @original_duration
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

    describe 'User with only :database_authenticatable and :registerable included' do
      setup do
        @request.env['devise.mapping'] = Devise.mappings[:only_email_user]
      end

      teardown do
        @request.env['devise.mapping'] = Devise.mappings[:user]
      end

      before do
        @existing_user = only_email_users(:user)
        @existing_user.save!

        xhr :post, :create, {
          email: @existing_user.email,
          password: 'secret123'
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test 'user should be able to sign in without confirmation' do
        assert 200, response.status
        refute OnlyEmailUser.method_defined?(:confirmed_at)
      end
    end

    describe "Lockable User" do
      setup do
        @request.env['devise.mapping'] = Devise.mappings[:lockable_user]
      end

      teardown do
        @request.env['devise.mapping'] = Devise.mappings[:user]
      end

      before do
        @original_lock_strategy = Devise.lock_strategy
        @original_unlock_strategy = Devise.unlock_strategy
        @original_maximum_attempts = Devise.maximum_attempts
        Devise.lock_strategy = :failed_attempts
        Devise.unlock_strategy = :email
        Devise.maximum_attempts = 5
      end

      after do
        Devise.lock_strategy = @original_lock_strategy
        Devise.maximum_attempts = @original_maximum_attempts
        Devise.unlock_strategy = @original_unlock_strategy
      end

      describe "locked user" do
        before do
          @locked_user = lockable_users(:locked_user)
          xhr :post, :create, {
            email: @locked_user.email,
            password: 'secret123'
          }
          @data = JSON.parse(response.body)
        end

        test "request should fail" do
          assert_equal 401, response.status
        end

        test "response should contain errors" do
          assert @data['errors']
          assert_equal @data['errors'], [I18n.t("devise_token_auth.sessions.not_confirmed", email: @locked_user.email)]
        end
      end

      describe "unlocked user with bad password" do
        before do
          @unlocked_user = lockable_users(:unlocked_user)
          xhr :post, :create, {
            email: @unlocked_user.email,
            password: 'bad-password'
          }
          @data = JSON.parse(response.body)
        end

        test "request should fail" do
          assert_equal 401, response.status
        end

        test "should increase failed_attempts" do
          assert_equal 1, @unlocked_user.reload.failed_attempts
        end

        test "response should contain errors" do
          assert @data['errors']
          assert_equal @data['errors'], [I18n.t("devise_token_auth.sessions.bad_credentials")]
        end

        describe 'after maximum_attempts should block the user' do
          before do
            4.times do
              xhr :post, :create, {
                email: @unlocked_user.email,
                password: 'bad-password'
              }
            end
            @data = JSON.parse(response.body)
          end

          test "should increase failed_attempts" do
            assert_equal 5, @unlocked_user.reload.failed_attempts
          end

          test "should block the user" do
            assert_equal true, @unlocked_user.reload.access_locked?
          end
        end
      end
    end
  end
end
