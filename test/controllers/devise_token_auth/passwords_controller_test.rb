require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DeviseTokenAuth::PasswordsControllerTest < ActionController::TestCase
  describe DeviseTokenAuth::PasswordsController do
    describe "Password reset" do
      before do
        @resource = users(:confirmed_email_user)
        @redirect_url = 'http://ng-token-auth.dev'
      end

      describe 'request password reset' do

        describe 'case-sensitive email' do
          before do
            xhr :post, :create, {
              email:        @resource.email,
              redirect_url: @redirect_url
            }

            @mail = ActionMailer::Base.deliveries.last
            @resource.reload

            @mail_config_name  = CGI.unescape(@mail.body.match(/config=([^&]*)&/)[1])
            @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=([^&]*)&/)[1])
            @mail_reset_token  = @mail.body.match(/reset_password_token=(.*)\"/)[1]
          end

          test 'response should return success status' do
            assert_equal 200, response.status
          end

          test 'action should send an email' do
            assert @mail
          end

          test 'the email should be addressed to the user' do
            assert_equal @mail.to.first, @resource.email
          end

          test 'the email body should contain a link with redirect url as a query param' do
            assert_equal @redirect_url, @mail_redirect_url
          end

          test 'the client config name should fall back to "default"' do
            assert_equal 'default', @mail_config_name
          end

          test 'the email body should contain a link with reset token as a query param' do
            user = User.reset_password_by_token({
              reset_password_token: @mail_reset_token
            })

            assert_equal user.id, @resource.id
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

              @resource.reload

              raw_qs = response.location.split('?')[1]
              @qs = Rack::Utils.parse_nested_query(raw_qs)

              @client_id      = @qs["client_id"]
              @expiry         = @qs["expiry"]
              @reset_password = @qs["reset_password"]
              @token          = @qs["token"]
              @uid            = @qs["uid"]
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
              assert @resource.valid_token?(@token, @client_id)
            end
          end

        end

        describe 'case-insensitive email' do
          before do
            @resource_class = User
            @request_params = {
              email:        @resource.email.upcase,
              redirect_url: @redirect_url
            }
          end

          test 'response should return success status if configured' do
            @resource_class.case_insensitive_keys = [:email]
            xhr :post, :create, @request_params
            assert_equal 200, response.status
          end

          test 'response should return failure status if not configured' do
            @resource_class.case_insensitive_keys = []
            xhr :post, :create, @request_params
            assert_equal 400, response.status
          end
        end
      end

      describe "change password" do
        describe 'success' do
          before do
            @auth_headers = @resource.create_new_auth_token
            request.headers.merge!(@auth_headers)
            @new_password = Faker::Internet.password

            xhr :put, :update, {
              password: @new_password,
              password_confirmation: @new_password
            }

            @resource.reload
          end

          test "request should be successful" do
            assert_equal 200, response.status
          end

          test "new password should authenticate user" do
            assert @resource.valid_password?(@new_password)
          end
        end

        describe 'password mismatch error' do
          before do
            @auth_headers = @resource.create_new_auth_token
            request.headers.merge!(@auth_headers)
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
            @auth_headers = @resource.create_new_auth_token
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

    describe "Alternate user class" do
      setup do
        @request.env['devise.mapping'] = Devise.mappings[:mang]
      end

      teardown do
        @request.env['devise.mapping'] = Devise.mappings[:user]
      end

      before do
        @resource = mangs(:confirmed_email_user)
        @redirect_url = 'http://ng-token-auth.dev'

        xhr :post, :create, {
          email:        @resource.email,
          redirect_url: @redirect_url
        }

        @mail = ActionMailer::Base.deliveries.last
        @resource.reload

        @mail_config_name  = CGI.unescape(@mail.body.match(/config=([^&]*)&/)[1])
        @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=([^&]*)&/)[1])
        @mail_reset_token  = @mail.body.match(/reset_password_token=(.*)\"/)[1]
      end

      test 'response should return success status' do
        assert_equal 200, response.status
      end

      test 'the email body should contain a link with reset token as a query param' do
        user = Mang.reset_password_by_token({
          reset_password_token: @mail_reset_token
        })

        assert_equal user.id, @resource.id
      end
    end

    describe 'unconfirmed user' do
      before do
        @resource = users(:unconfirmed_email_user)
        @redirect_url = 'http://ng-token-auth.dev'

        xhr :post, :create, {
          email:        @resource.email,
          redirect_url: @redirect_url
        }

        @mail = ActionMailer::Base.deliveries.last
        @resource.reload

        @mail_config_name  = CGI.unescape(@mail.body.match(/config=([^&]*)&/)[1])
        @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=([^&]*)&/)[1])
        @mail_reset_token  = @mail.body.match(/reset_password_token=(.*)\"/)[1]

        xhr :get, :edit, {
          reset_password_token: @mail_reset_token,
          redirect_url: @mail_redirect_url
        }

        @resource.reload
      end

      test 'unconfirmed email user should now be confirmed' do
        assert @resource.confirmed_at
      end
    end

    describe 'alternate user type' do
      before do
        @resource         = users(:confirmed_email_user)
        @redirect_url = 'http://ng-token-auth.dev'
        @config_name  = "altUser"

        xhr :post, :create, {
          email:        @resource.email,
          redirect_url: @redirect_url,
          config_name:  @config_name
        }

        @mail = ActionMailer::Base.deliveries.last
        @resource.reload

        @mail_config_name  = CGI.unescape(@mail.body.match(/config=([^&]*)&/)[1])
        @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=([^&]*)&/)[1])
        @mail_reset_token  = @mail.body.match(/reset_password_token=(.*)\"/)[1]
      end

      test 'config_name param is included in the confirmation email link' do
        assert_equal @config_name, @mail_config_name
      end
    end
  end
end
