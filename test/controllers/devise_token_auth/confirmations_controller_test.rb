require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DeviseTokenAuth::ConfirmationsControllerTest < ActionController::TestCase
  describe DeviseTokenAuth::ConfirmationsController do
    def token_and_client_config_from(body)
      token         = body.match(/confirmation_token=([^&]*)&/)[1]
      client_config = body.match(/config=([^&]*)&/)[1]
      [token, client_config]
    end

    describe "Confirmation" do
      before do
        @redirect_url = Faker::Internet.url
        @new_user = users(:unconfirmed_email_user)
        @new_user.send_confirmation_instructions({
          redirect_url: @redirect_url
        })
        mail = ActionMailer::Base.deliveries.last
        @token, @client_config = token_and_client_config_from(mail.body)
      end

      test 'should generate raw token' do
        assert @token
      end

      test "should include config name as 'default' in confirmation link" do
        assert_equal "default", @client_config
      end

      test "should store token hash in user" do
        assert @new_user.confirmation_token
      end

      describe "success" do
        before do
          xhr :get, :show, {confirmation_token: @token, redirect_url: @redirect_url}
          @resource = assigns(:resource)
        end

        test "user should now be confirmed" do
          assert @resource.confirmed?
        end

        test "should redirect to success url" do
          assert_redirected_to(/^#{@redirect_url}/)
        end
      end

      describe "failure" do
        test "user should not be confirmed" do
          assert_raises(ActionController::RoutingError) {
            xhr :get, :show, {confirmation_token: "bogus"}
          }
          @resource = assigns(:resource)
          refute @resource.confirmed?
        end
      end
    end

    # test with non-standard user class
    describe "Alternate user model" do
      setup do
        @request.env['devise.mapping'] = Devise.mappings[:mang]
      end

      teardown do
        @request.env['devise.mapping'] = Devise.mappings[:user]
      end

      before do
        @config_name = "altUser"
        @new_user    = mangs(:unconfirmed_email_user)

        @new_user.send_confirmation_instructions(client_config: @config_name)

        mail = ActionMailer::Base.deliveries.last
        @token, @client_config = token_and_client_config_from(mail.body)
      end

      test 'should generate raw token' do
        assert @token
      end

      test "should include config name in confirmation link" do
        assert_equal @config_name, @client_config
      end

      test "should store token hash in user" do
        assert @new_user.confirmation_token
      end

      describe "success" do
        before do
          @redirect_url = Faker::Internet.url
          xhr :get, :show, {confirmation_token: @token, redirect_url: @redirect_url}
          @resource = assigns(:resource)
        end

        test "user should now be confirmed" do
          assert @resource.confirmed?
        end
      end
    end
  end
end
