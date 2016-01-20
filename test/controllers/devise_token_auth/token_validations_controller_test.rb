require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DeviseTokenAuth::TokenValidationsControllerTest < ActionDispatch::IntegrationTest
  test_registrations = lambda do |orm|
    test_mongoid = (orm == 'Mongoid')
    if test_mongoid
      auth_url = 'mongoid_user_auth'
      user_class = MongoidUser
      describe_orm_txt = "Mongoid user"
    else
      auth_url = 'auth'
      user_class = User
      describe_orm_txt = "ActiveRecord user"
    end

    describe describe_orm_txt do
      describe DeviseTokenAuth::TokenValidationsController do
        before do
          @resource = get_confirmed_email_user_obj test_mongoid
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
            get "/#{auth_url}/validate_token", {}, @auth_headers
            @resp = JSON.parse(response.body)
          end

          test "token valid" do
            assert_equal 200, response.status
          end
        end

        describe 'using namespaces' do
          before do
            get "/api/v1/#{auth_url}/validate_token", {}, @auth_headers
            @resp = JSON.parse(response.body)
          end

          test "token valid" do
            assert_equal 200, response.status
          end
        end

        describe 'failure' do
          before do
            get "/api/v1/#{auth_url}/validate_token", {}, @auth_headers.merge({"access-token" => "12345"})
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
          if test_mongoid
            @resource = create(:mongoid_scoped_user)
          else
            @resource = scoped_users(:confirmed_email_user)
          end
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
          get "/api_v2/#{auth_url}/validate_token", {}, @auth_headers
          assert_equal 200, response.status
        end

      end
    end
  end

  # test ActiveRecord object
  test_registrations.call 'ActiveRecord'
  # test Mongoid object
  test_registrations.call 'Mongoid'

end
