require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DeviseTokenAuth::TokenValidationsControllerTest < ActionDispatch::IntegrationTest
  describe DeviseTokenAuth::TokenValidationsController do
    before do
      @resource = users(:confirmed_email_user)
      @resource.skip_confirmation!
      @resource.save!

      @auth_headers = @resource.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']

      # ensure that request is not treated as batch request
      age_token(@resource, @client_id)

    end

    describe 'vanilla user' do
      before do
        get '/auth/validate_token', {}, @auth_headers
        @resp = JSON.parse(response.body)
      end

      test "token valid" do
        assert_equal 200, response.status
      end
    end

    describe 'using namespaces' do
      before do
        get '/api/v1/auth/validate_token', {}, @auth_headers
        @resp = JSON.parse(response.body)
      end

      test "token valid" do
        assert_equal 200, response.status
      end
    end
  end
end
