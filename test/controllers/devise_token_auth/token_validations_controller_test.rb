require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DeviseTokenAuth::TokenValidationsControllerTest < ActionDispatch::IntegrationTest

  describe 'custom json format' do

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

      describe 'failure' do
        before do
          get '/api/v1/auth/validate_token', {}, @auth_headers.merge({"access-token" => "12345"})
          @resp = JSON.parse(response.body)
        end

        test "request should fail" do
          assert_equal 401, response.status
        end

        test "response should contain errors" do
          assert @resp['errors']
          assert_equal @resp['errors'], [I18n.t("devise_token_auth.token_validations.invalid")]
        end
      end

    end

    describe 'using namespaces with unused resource' do

      before do
        @resource = scoped_users(:confirmed_email_user)
        @resource.skip_confirmation!
        @resource.save!

        @auth_headers = @resource.create_new_auth_token

        @token     = @auth_headers['access-token']
        @client_id = @auth_headers['client']
        @expiry    = @auth_headers['expiry']

        # ensure that request is not treated as batch request
        age_token(@resource, @client_id)
      end

      test "should be successful" do
        get '/api_v2/auth/validate_token', {}, @auth_headers
        assert_equal 200, response.status
      end

    end

  end

  describe 'JSON API compliant format' do
    before do
      @request.env['HTTP_CONTENT_TYPE'] = 'application/vnd.api+json' if @request.present?
      @request.env['HTTP_ACCEPT'] = 'application/vnd.api+json' if @request.present?
      @additional_headers = {
        'HTTP_ACCEPT' => 'application/vnd.api+json',
        'HTTP_CONTENT_TYPE' => 'application/vnd.api+json'
      }
    end

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
          get '/auth/validate_token', json_api_params({}), @auth_headers.merge(@additional_headers)
          @resp = JSON.parse(response.body)
        end

        test "token valid" do
          assert_equal 200, response.status
        end
      end

      describe 'using namespaces' do
        before do
          get '/api/v1/auth/validate_token', json_api_params({}), @auth_headers
          @resp = JSON.parse(response.body)
        end

        test "token valid" do
          assert_equal 200, response.status
        end
      end

      describe 'failure' do
        before do
          get '/api/v1/auth/validate_token', json_api_params({}), @auth_headers.merge({"access-token" => "12345"}).merge(@additional_headers)
          @resp = JSON.parse(response.body)
        end

        test "request should fail" do
          assert_equal 401, response.status
        end

        test "response should contain errors" do
          assert_json_match({
            errors: [{
              detail: I18n.t("devise_token_auth.token_validations.invalid")
            }]
          }, @resp)
        end
      end

    end

    describe 'using namespaces with unused resource' do

      before do
        @resource = scoped_users(:confirmed_email_user)
        @resource.skip_confirmation!
        @resource.save!

        @auth_headers = @resource.create_new_auth_token

        @token     = @auth_headers['access-token']
        @client_id = @auth_headers['client']
        @expiry    = @auth_headers['expiry']

        # ensure that request is not treated as batch request
        age_token(@resource, @client_id)
      end

      test "should be successful" do
        get '/api_v2/auth/validate_token', json_api_params({}), @auth_headers.merge(@additional_headers)
        assert_equal 200, response.status
      end

    end

  end

end
