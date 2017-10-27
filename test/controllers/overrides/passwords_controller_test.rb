require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class Overrides::PasswordsControllerTest < ActionDispatch::IntegrationTest
  describe Overrides::PasswordsController do
    before do
      @resource = evil_users(:confirmed_email_user)
      @redirect_url = Faker::Internet.url

      post '/evil_user_auth/password',
           params: {
             email: @resource.email,
             redirect_url: @redirect_url
           }

      @mail = ActionMailer::Base.deliveries.last
      @resource.reload

      @mail_config_name  = CGI.unescape(@mail.body.match(/config=([^&]*)&/)[1])
      @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=([^&]*)&/)[1])
      @mail_reset_token  = @mail.body.match(/reset_password_token=(.*)\"/)[1]

      get '/evil_user_auth/password/edit',
          params: { reset_password_token: @mail_reset_token,
                    redirect_url: @mail_redirect_url }

      @resource.reload

      raw_qs = response.location.split('?')[1]
      @qs = Rack::Utils.parse_nested_query(raw_qs)

      @access_token   = @qs['access-token']
      @client         = @qs['client']
      @client_id      = @qs['client_id']
      @expiry         = @qs['expiry']
      @override_proof = @qs['override_proof']
      @reset_password = @qs['reset_password']
      @token          = @qs['token']
      @uid            = @qs['uid']
    end

    test 'response should have success redirect status' do
      assert_equal 302, response.status
    end

    test 'response should contain auth params + override proof' do
      assert @access_token
      assert @client
      assert @client_id
      assert @expiry
      assert @override_proof
      assert @reset_password
      assert @token
      assert @uid
    end

    test 'override proof is correct' do
      assert_equal @override_proof, Overrides::PasswordsController::OVERRIDE_PROOF
    end
  end
end
