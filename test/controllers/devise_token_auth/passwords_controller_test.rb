require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DeviseTokenAuth::PasswordsControllerTest < ActionController::TestCase
  describe DeviseTokenAuth::PasswordsController, "Password reset" do
    fixtures :users

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

        #@token = @mail.body.match(/confirmation_token=(.*)\"/)[1]
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
        binding.pry
      end
    end
  end
end

