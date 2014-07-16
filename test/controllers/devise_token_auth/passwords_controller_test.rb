require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DeviseTokenAuth::PasswordsControllerTest < ActionController::TestCase
  describe DeviseTokenAuth::PasswordsController, "Password reset" do
    before do
      @user = users(:confirmed_email_user)
      @redirect_url = 'http://ng-token-auth.dev'
    end

    describe 'request password reset' do
      before do
        xhr :post, :create, {
          email:        @user.email,
          redirect_url: @redirect_url
        }

        @mail = ActionMailer::Base.deliveries.last
        @user.reload

        @mail_reset_token  = @mail.body.match(/reset_password_token=(.*)\"/)[1]
        @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=(.*)&amp;/)[1])
      end

      test 'response should return success status' do
        assert_equal 200, response.status
      end

      test 'action should save password_reset_redirect_url to user table' do
        assert_equal @redirect_url, @user.reset_password_redirect_url
      end

      test 'action should send an email' do
        assert @mail
      end

      test 'the email should be addressed to the user' do
        assert_equal @mail.to.first, @user.email
      end

      test 'the email body should contain a link with redirect url as a query param' do
        assert_equal @redirect_url, @mail_redirect_url
      end

      test 'the email body should contain a link with reset token as a query param' do
        user = User.reset_password_by_token({
          reset_password_token: @mail_reset_token
        })

        assert_equal user.id, @user.id
      end

      describe 'password reset link failure' do
        test 'request should not be authorized' do
          assert_raises(ActionController::RoutingError) {
            xhr :get, :edit, {
              reset_password_token: 'bogus',
              redirect_url: @mail_redirect_url
            }
          }
        end
      end

      describe 'password reset link success' do
        before do
          xhr :get, :edit, {
            reset_password_token: @mail_reset_token,
            redirect_url: @mail_redirect_url
          }

          @user.reload

          @uri = URI.parse(response.location)
          @qs = CGI::parse(@uri.query)

          @client_id      = @qs["client_id"].first
          @expiry         = @qs["expiry"].first
          @reset_password = @qs["reset_password"].first
          @token          = @qs["token"].first
          @uid            = @qs["uid"].first
        end

        test 'respones should have success redirect status' do
          assert_equal 302, response.status
        end

        test 'response should contain auth params' do
          assert @client_id
          assert @expiry
          assert @reset_password
          assert @token
          assert @uid
        end

        test 'response auth params should be valid' do
          assert @user.valid_token?(@token, @client_id)
        end
      end
    end

    describe "change password" do
      describe 'success' do
        before do
          @auth_header = @user.create_new_auth_token
          request.headers['Authorization'] = @auth_header
          @new_password = Faker::Internet.password

          xhr :put, :update, {
            password: @new_password,
            password_confirmation: @new_password
          }

          @user.reload
        end

        test "request should be successful" do
          assert_equal 200, response.status
        end

        test "new password should authenticate user" do
          assert @user.valid_password?(@new_password)
        end
      end

      describe 'password mismatch error' do
        before do
          @auth_header = @user.create_new_auth_token
          request.headers['Authorization'] = @auth_header
          @new_password = Faker::Internet.password

          xhr :put, :update, {
            password: 'chong',
            password_confirmation: 'bong'
          }
        end

        test 'response should fail' do
          assert_equal 422, response.status
        end
      end

      describe 'unauthorized user' do
        before do
          @auth_header = @user.create_new_auth_token
          @new_password = Faker::Internet.password

          xhr :put, :update, {
            password: @new_password,
            password_confirmation: @new_password
          }
        end

        test 'response should fail' do
          assert_equal 401, response.status
        end
      end
    end
  end

  describe DeviseTokenAuth::PasswordsController, "Alternate user class" do
    setup do
      @request.env['devise.mapping'] = Devise.mappings[:mang]
    end

    teardown do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    before do
      @user = mangs(:confirmed_email_user)
      @redirect_url = 'http://ng-token-auth.dev'

      xhr :post, :create, {
        email:        @user.email,
        redirect_url: @redirect_url
      }

      @mail = ActionMailer::Base.deliveries.last
      @user.reload

      @mail_reset_token  = @mail.body.match(/reset_password_token=(.*)\"/)[1]
      @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=(.*)&amp;/)[1])
    end

    test 'response should return success status' do
      assert_equal 200, response.status
    end

    test 'the email body should contain a link with reset token as a query param' do
      user = Mang.reset_password_by_token({
        reset_password_token: @mail_reset_token
      })

      assert_equal user.id, @user.id
    end
  end
end

