require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class Overrides::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  describe Overrides::RegistrationsController do
    before do
      @existing_user = evil_users(:confirmed_email_user)
      @existing_user.skip_confirmation!
      @existing_user.save!

      post '/evil_user_auth/sign_in',
           params: { email: @existing_user.email,
                     password: 'secret123' }

      @resource = assigns(:resource)
      @data = JSON.parse(response.body)
    end

    test 'request should succeed' do
      assert_equal 200, response.status
    end

    test 'controller was overridden' do
      assert_equal Overrides::RegistrationsController::OVERRIDE_PROOF,
                   @data['override_proof']
    end
  end
end
