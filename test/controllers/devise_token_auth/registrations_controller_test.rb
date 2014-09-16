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
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url,
          unpermitted_param: '(x_x)'
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

      test "confirm_success_url be allowed by strong params" do
        assert @data['data']['confirm_success_url']
      end

      test "new user should receive confirmation email" do
        assert_equal @user.email, @mail['to'].to_s
      end

      test "new user password should not be returned" do
        assert_nil @data['data']['password']
      end
    end

    describe "Adding extra params" do
      before do
        xhr :post, :create, {
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url,
          operating_thetan: 2
        }

        @user = assigns(:resource)
        @data = JSON.parse(response.body)
        @mail = ActionMailer::Base.deliveries.last
      end

      test "Additional sign_up params should be considered" do
        assert_equal 2, @user.operating_thetan
      end
    end

    describe "Mismatched passwords" do
      before do
        xhr :post, :create, {
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "bogus",
          confirm_success_url: Faker::Internet.url
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
          confirm_success_url: Faker::Internet.url
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


    describe "Destroy user account" do
      describe "success" do
        before do
          @existing_user = users(:confirmed_email_user)
          @auth_headers  = @existing_user.create_new_auth_token
          @client_id     = @auth_headers['client']

          # ensure request is not treated as batch request
          age_token(@existing_user, @client_id)

          # add auth headers for user identification
          request.headers.merge!(@auth_headers)

          xhr :delete, :destroy

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
          xhr :delete, :destroy
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

          # add auth headers for user identification
          request.headers.merge!(@auth_headers)

        end

        describe "success" do
          before do
            # test valid update param
            @new_operating_thetan = 1000000

            xhr :put, :update, {
              operating_thetan: @new_operating_thetan
            }

            @data = JSON.parse(response.body)
            @existing_user.reload
          end

          test "Request was successful" do
            assert_equal 200, response.status
          end

          test "User attribute was updated" do
            assert_equal @new_operating_thetan, @existing_user.operating_thetan
          end
        end

        describe "error" do
          before do
            # test invalid update param
            @new_operating_thetan = "blegh"
            xhr :put, :update, {
              operating_thetan: @new_operating_thetan
            }

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

          # add auth headers for user identification
          request.headers.merge!(@auth_headers)

          # test valid update param
          @new_operating_thetan = 3

          xhr :put, :update, {
            operating_thetan: @new_operating_thetan
          }

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

        xhr :post, :create, {
          email: @existing_user.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url
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
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url
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

      test "Mang should be destroyed" do
        @auth_headers  = @user.create_new_auth_token
        @client_id     = @auth_headers['client']

        # ensure request is not treated as batch request
        age_token(@user, @client_id)

        # add auth headers for user identification
        request.headers.merge!(@auth_headers)

        xhr :delete, :destroy

        assert_equal 200, response.status
        refute Mang.where(id: @user.id).first
      end
    end


    describe "Alternate user class - passing client config name" do
      setup do
        @request.env['devise.mapping'] = Devise.mappings[:mang]
      end

      teardown do
        @request.env['devise.mapping'] = Devise.mappings[:user]
      end

      before do
        @config_name = 'altUser'

        xhr :post, :create, {
          email: Faker::Internet.email,
          password: "secret123",
          password_confirmation: "secret123",
          confirm_success_url: Faker::Internet.url,
          config_name: @config_name
        }

        @user = assigns(:resource)
        @data = JSON.parse(response.body)
        @mail = ActionMailer::Base.deliveries.last

        @mail = ActionMailer::Base.deliveries.last
        @user.reload

        @mail_reset_token  = @mail.body.match(/confirmation_token=(.*)\"/)[1]
        @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=(.*)&amp;/)[1])
        @mail_config_name  = CGI.unescape(@mail.body.match(/config=(.*)&amp;/)[1])
      end

      test 'config_name param is included in the confirmation email link' do
        assert_equal @config_name, @mail_config_name
      end
    end
  end
end
