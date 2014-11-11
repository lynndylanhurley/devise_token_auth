require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class OmniauthTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
      :provider => 'facebook',
      :uid => '123545',
      :info => {
        name: 'chong',
        email: 'chongbong@aol.com'
      }
    })
  end

  before do
    @redirect_url = "http://ng-token-auth.dev/"
  end

  describe 'default user model' do
    describe 'from api to provider' do
      before do
        get_via_redirect '/auth/facebook', {
          auth_origin_url: @redirect_url
        }

        @resource = assigns(:resource)
      end

      test 'status should be success' do
        assert_equal 200, response.status
      end

      test 'request should determine the correct resource_class' do
        assert_equal 'User', controller.omniauth_params['resource_class']
      end

      test 'request should pass correct redirect_url' do
        assert_equal @redirect_url, controller.omniauth_params['auth_origin_url']
      end

      test 'user should have been created' do
        assert @resource
      end

      test 'user should be assigned info from provider' do
        assert_equal 'chongbong@aol.com', @resource.email
      end

      test 'user should be of the correct class' do
        assert_equal User, @resource.class
      end

      test 'response contains all serializable attributes for user' do
        post_message = JSON.parse(/postMessage\((?<data>.*), '\*'\);/m.match(response.body)[:data])

        assert post_message["id"]
        assert post_message["email"]
        assert post_message["uid"]
        assert post_message["name"]
        assert post_message["favorite_color"]
        assert post_message["message"]
        assert post_message["client_id"]
        assert post_message["auth_token"]
        refute post_message["tokens"]
        refute post_message["password"]
      end

      test 'session vars have been cleared' do
        refute request.session['dta.omniauth.auth']
        refute request.session['dta.omniauth.params']
      end

      describe 'trackable' do
        test 'sign_in_count incrementns' do
          assert @resource.sign_in_count > 0
        end

        test 'current_sign_in_at is updated' do
          assert @resource.current_sign_in_at
        end

        test 'last_sign_in_at is updated' do
          assert @resource.last_sign_in_at
        end

        test 'sign_in_ip is updated' do
          assert @resource.current_sign_in_ip
        end

        test 'last_sign_in_ip is updated' do
          assert @resource.last_sign_in_ip
        end
      end

    end

    describe 'pass additional params' do
      before do
        @fav_color = 'alizarin crimson'
        @unpermitted_param = "M. Bison"
        get_via_redirect '/auth/facebook', {
          auth_origin_url: @redirect_url,
          favorite_color: @fav_color,
          name: @unpermitted_param
        }

        @resource = assigns(:resource)
      end

      test 'status shows success' do
        assert_equal 200, response.status
      end

      test 'additional attribute was passed' do
        assert_equal @fav_color, @resource.favorite_color
      end

      test 'non-whitelisted attributes are ignored' do
        refute_equal @unpermitted_param, @resource.name
      end
    end
  end


  describe 'alternate user model' do
    describe 'from api to provider' do
      before do
        get_via_redirect '/mangs/facebook', {
          auth_origin_url: @redirect_url
        }

        @resource = assigns(:resource)
      end

      test 'status should be success' do
        assert_equal 200, response.status
      end

      test 'request should determine the correct resource_class' do
        assert_equal 'Mang', controller.omniauth_params['resource_class']
      end

      test 'request should pass correct redirect_url' do
        assert_equal @redirect_url, controller.omniauth_params['auth_origin_url']
      end

      test 'user should have been created' do
        assert @resource
      end

      test 'user should be assigned info from provider' do
        assert_equal 'chongbong@aol.com', @resource.email
      end

      test 'user should be of the correct class' do
        assert_equal Mang, @resource.class
      end
    end
  end
end
