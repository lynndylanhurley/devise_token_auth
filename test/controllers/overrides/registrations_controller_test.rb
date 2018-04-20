require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class Overrides::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  describe Overrides::RegistrationsController do
    describe 'Succesful Registration update' do
      setup do
        @existing_user  = evil_users(:confirmed_email_user)
        @auth_headers   = @existing_user.create_new_auth_token
        @client_id      = @auth_headers['client']
        @favorite_color = 'pink'

        # ensure request is not treated as batch request
        age_token(@existing_user, @client_id)

        # test valid update param
        @new_operating_thetan = 1_000_000

        put '/evil_user_auth',
            params: { favorite_color: @favorite_color },
            headers: @auth_headers

        @data = JSON.parse(response.body)
        @existing_user.reload
      end

      test 'user was updated' do
        assert_equal @favorite_color, @existing_user.favorite_color
      end

      test 'controller was overridden' do
        assert_equal Overrides::RegistrationsController::OVERRIDE_PROOF,
                     @data['override_proof']
      end
    end

    describe 'Successful registration' do
      before do
        post '/auth',
             params: {
               email: Faker::Internet.email,
               password: 'secret123',
               password_confirmation: 'secret123',
               confirm_success_url: Faker::Internet.url,
               unpermitted_param: '(x_x)'
             }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      test 'request should be successful' do
        assert_equal 200, response.status
      end

      test 'user should have been created' do
        assert @resource.id
      end

      test 'user should not be confirmed' do
        assert_nil @resource.confirmed_at
      end
    end
  end
end
