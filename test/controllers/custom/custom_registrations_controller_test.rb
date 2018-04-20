require 'test_helper'

class Custom::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  describe Custom::RegistrationsController do
    setup do
      @create_params = {
        email: Faker::Internet.email,
        password: 'secret123',
        password_confirmation: 'secret123',
        confirm_success_url: Faker::Internet.url,
        unpermitted_param: '(x_x)'
      }

      @existing_user = nice_users(:confirmed_email_user)
      @auth_headers  = @existing_user.create_new_auth_token
      @client_id     = @auth_headers['client']

      # ensure request is not treated as batch request
      age_token(@existing_user, @client_id)
    end

    test 'yield resource to block on create success' do
      post '/nice_user_auth', params: @create_params
      assert @controller.create_block_called?,
             'create failed to yield resource to provided block'
    end

    test 'yield resource to block on create success with custom json' do
      post '/nice_user_auth', params: @create_params

      @data = JSON.parse(response.body)

      assert @controller.create_block_called?,
             'create failed to yield resource to provided block'
      assert_equal @data['custom'], 'foo'
    end

    test 'yield resource to block on update success' do
      put '/nice_user_auth',
          params: {
            nickname: "Ol' Sunshine-face"
          },
          headers: @auth_headers
      assert @controller.update_block_called?,
             'update failed to yield resource to provided block'
    end

    test 'yield resource to block on destroy success' do
      delete '/nice_user_auth', headers: @auth_headers
      assert @controller.destroy_block_called?,
             'destroy failed to yield resource to provided block'
    end

    describe 'when overriding #build_resource' do
      setup do
        class Custom::RegistrationsController
          def build_resource
            # do not deffine resource as expected
          end
        end
      end

      test 'it fails' do
        assert_raises DeviseTokenAuth::Errors::NoResourceDefinedError do
          post '/nice_user_auth', params: @create_params
        end
      end

      teardown do
        # This stubbing could be better
        class Custom::RegistrationsController
          def build_resource
            @resource            = resource_class.new(sign_up_params)
            @resource.provider   = provider

            # honor devise configuration for case_insensitive_keys
            if resource_class.case_insensitive_keys.include?(:email)
              @resource.email = sign_up_params[:email].try(:downcase)
            else
              @resource.email = sign_up_params[:email]
            end
          end
        end
      end
    end
  end
end
