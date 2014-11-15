require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?


class DeviseTokenAuth::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  describe DeviseTokenAuth::RegistrationsController do
    describe "Successful registration" do
      before do
        @mails_sent = ActionMailer::Base.deliveries.count

        post '/auth', {
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url,
          unpermitted_param: '(x_x)'
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
        @mail = ActionMailer::Base.deliveries.last
      end

      test "request should be successful" do
        assert_equal 200, response.status
      end

      test "user should have been created" do
        assert @resource.id
      end

      test "user should not be confirmed" do
        assert_nil @resource.confirmed_at
      end

      test "new user data should be returned as json" do
        assert @data['data']['email']
      end

      test "new user should receive confirmation email" do
        assert_equal @resource.email, @mail['to'].to_s
      end

      test "new user password should not be returned" do
        assert_nil @data['data']['password']
      end

      test "only one email was sent" do
        assert_equal @mails_sent + 1, ActionMailer::Base.deliveries.count
      end
    end

    describe "case-insensitive email" do

      before do
        @resource_class = User
        @request_params = {
          email: "AlternatingCase@example.com",
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url
        }
      end

      test "success should downcase uid if configured" do
        @resource_class.case_insensitive_keys = [:email]
        post '/auth', @request_params
        assert_equal 200, response.status
        @data = JSON.parse(response.body)
        assert_equal "alternatingcase@example.com", @data['data']['uid']
      end

      test "request should not downcase uid if not configured" do
        @resource_class.case_insensitive_keys = []
        post '/auth', @request_params
        assert_equal 200, response.status
        @data = JSON.parse(response.body)
        assert_equal "AlternatingCase@example.com", @data['data']['uid']
      end

    end

    describe "Adding extra params" do
      before do
        @redirect_url     = Faker::Internet.url
        @operating_thetan = 2

        post '/auth', {
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: @redirect_url,
          favorite_color: @fav_color,
          operating_thetan: @operating_thetan
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
        @mail = ActionMailer::Base.deliveries.last

        @mail_reset_token  = @mail.body.match(/confirmation_token=([^&]*)&/)[1]
        @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=(.*)\"/)[1])
        @mail_config_name  = CGI.unescape(@mail.body.match(/config=([^&]*)&/)[1])
      end

      test 'redirect_url is included as param in email' do
        assert_equal @redirect_url, @mail_redirect_url
      end

      test "additional sign_up params should be considered" do
        assert_equal @operating_thetan, @resource.operating_thetan
      end

      test 'config_name param is included in the confirmation email link' do
        assert @mail_config_name
      end

      test "client config name falls back to 'default'" do
        assert_equal "default", @mail_config_name
      end
    end

    describe "Mismatched passwords" do
      before do
        post '/auth', {
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "bogus",
          confirm_success_url: Faker::Internet.url
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test "request should not be successful" do
        assert_equal 403, response.status
      end

      test "user should have been created" do
        assert_nil @resource.id
      end

      test "error should be returned in the response" do
        assert @data['errors'].length
      end

      test "full_messages should be included in error hash" do
        assert @data['errors']['full_messages'].length
      end
    end

    describe "Existing users" do
      before do
        @existing_user = users(:confirmed_email_user)

        post "/auth", {
          email: @existing_user.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test "request should not be successful" do
        assert_equal 403, response.status
      end

      test "user should have been created" do
        assert_nil @resource.id
      end

      test "error should be returned in the response" do
        assert @data['errors'].length
      end
    end


    describe "Destroy user account" do
      describe "success" do
        before do
          @existing_user = users(:confirmed_email_user)
          @auth_headers  = @existing_user.create_new_auth_token
          @client_id     = @auth_headers['client']

          # ensure request is not treated as batch request
          age_token(@existing_user, @client_id)

          delete "/auth", {}, @auth_headers

          @data = JSON.parse(response.body)
        end

        test 'request is successful' do
          assert_equal 200, response.status
        end

        test "existing user should be deleted" do
          refute User.where(id: @existing_user.id).first
        end
      end

      describe 'failure: no auth headers' do
        before do
          delete "/auth"
          @data = JSON.parse(response.body)
        end

        test 'request returns 404 (not found) status' do
          assert_equal 404, response.status
        end
      end
    end


    describe "Update user account" do
      describe "existing user" do
        before do
          @existing_user = users(:confirmed_email_user)
          @auth_headers  = @existing_user.create_new_auth_token
          @client_id     = @auth_headers['client']

          # ensure request is not treated as batch request
          age_token(@existing_user, @client_id)
        end

        describe "success" do
          before do
            # test valid update param
            @resource_class = User
            @new_operating_thetan = 1000000
            @email = "AlternatingCase2@example.com"
            @request_params = {
              operating_thetan: @new_operating_thetan,
              email: @email
            }
          end

          test "Request was successful" do
            put "/auth", @request_params, @auth_headers
            assert_equal 200, response.status
          end

          test "Case sensitive attributes update" do
            @resource_class.case_insensitive_keys = []
            put "/auth", @request_params, @auth_headers
            @data = JSON.parse(response.body)
            @existing_user.reload
            assert_equal @new_operating_thetan, @existing_user.operating_thetan
            assert_equal @email, @existing_user.email
            assert_equal @email, @existing_user.uid
          end

          test "Case insensitive attributes update" do
            @resource_class.case_insensitive_keys = [:email]
            put "/auth", @request_params, @auth_headers
            @data = JSON.parse(response.body)
            @existing_user.reload
            assert_equal @new_operating_thetan, @existing_user.operating_thetan
            assert_equal @email.downcase, @existing_user.email
            assert_equal @email.downcase, @existing_user.uid
          end
        end

        describe "error" do
          before do
            # test invalid update param
            @new_operating_thetan = "blegh"
            put "/auth", {
              operating_thetan: @new_operating_thetan
            }, @auth_headers

            @data = JSON.parse(response.body)
            @existing_user.reload
          end

          test "Request was NOT successful" do
            assert_equal 403, response.status
          end

          test "Errors were provided with response" do
            assert @data["errors"].length
          end
        end
      end

      describe "invalid user" do
        before do
          @existing_user = users(:confirmed_email_user)
          @auth_headers  = @existing_user.create_new_auth_token
          @client_id     = @auth_headers['client']

          # ensure request is not treated as batch request
          expire_token(@existing_user, @client_id)

          # test valid update param
          @new_operating_thetan = 3

          put "/auth", {
            operating_thetan: @new_operating_thetan
          }, @auth_headers

          @data = JSON.parse(response.body)
          @existing_user.reload
        end

        test "Response should return 404 status" do
          assert_equal 404, response.status
        end

        test "User should not be updated" do
          refute_equal @new_operating_thetan, @existing_user.operating_thetan
        end
      end
    end

    describe "Ouath user has existing email" do
      before do
        @existing_user = users(:duplicate_email_facebook_user)

        post "/auth", {
          email: @existing_user.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test "request should be successful" do
        assert_equal 200, response.status
      end

      test "user should have been created" do
        assert @resource.id
      end

      test "new user data should be returned as json" do
        assert @data['data']['email']
      end
    end

    describe "Alternate user class" do
      before do
        post "/mangs", {
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
        @mail = ActionMailer::Base.deliveries.last
      end

      test "request should be successful" do
        assert_equal 200, response.status
      end

      test "use should be a Mang" do
        assert_equal "Mang", @resource.class.name
      end

      test "Mang should be destroyed" do
        @auth_headers  = @resource.create_new_auth_token
        @client_id     = @auth_headers['client']

        # ensure request is not treated as batch request
        age_token(@resource, @client_id)

        delete "/mangs", {}, @auth_headers

        assert_equal 200, response.status
        refute Mang.where(id: @resource.id).first
      end
    end

    describe "Passing client config name" do
      before do
        @config_name = 'altUser'

        post "/mangs", {
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url,
          config_name: @config_name
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
        @mail = ActionMailer::Base.deliveries.last

        @resource.reload

        @mail_reset_token  = @mail.body.match(/confirmation_token=([^&]*)&/)[1]
        @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=(.*)\"/)[1])
        @mail_config_name  = CGI.unescape(@mail.body.match(/config=([^&]*)&/)[1])
      end

      test 'config_name param is included in the confirmation email link' do
        assert_equal @config_name, @mail_config_name
      end
    end

    describe "Skipped confirmation" do
      setup do
        User.set_callback(:create, :before, :skip_confirmation!)

        post "/auth", {
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url
        }

        @resource  = assigns(:resource)
        @token     = response.headers["access-token"]
        @client_id = response.headers["client"]
      end

      teardown do
        User.skip_callback(:create, :before, :skip_confirmation!)
      end

      test "user was created" do
        assert @resource
      end

      test "user was confirmed" do
        assert @resource.confirmed?
      end

      test "auth headers were returned in response" do
        assert response.headers["access-token"]
        assert response.headers["token-type"]
        assert response.headers["client"]
        assert response.headers["expiry"]
        assert response.headers["uid"]
      end

      test "response token is valid" do
        assert @resource.valid_token?(@token, @client_id)
      end
    end
  end
end
