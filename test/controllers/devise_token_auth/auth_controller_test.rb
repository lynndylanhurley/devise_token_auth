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

        @user = assigns(:user)
      end

      test 'status should be success' do
        assert_equal 200, response.status
      end

      test 'request should determine the correct resource_class' do
        assert_equal 'User', request.env['omniauth.params']['resource_class']
      end

      test 'request should pass correct redirect_url' do
        assert_equal @redirect_url, request.env['omniauth.params']['auth_origin_url']
      end

      test 'user should have been created' do
        assert @user
      end

      test 'user should be assigned info from provider' do
        assert_equal 'chongbong@aol.com', @user.email
      end

      test 'user should be of the correct class' do
        assert_equal User, @user.class
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
        refute post_message["tokens"]
        refute post_message["password"]
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

        @user = assigns(:user)
      end

      test 'status shows success' do
        assert_equal 200, response.status
      end

      test 'additional attribute was passed' do
        assert_equal @fav_color, @user.favorite_color
      end

      test 'non-whitelisted attributes are ignored' do
        refute_equal @unpermitted_param, @user.name
      end
    end
  end


  describe 'alternate user model' do
    describe 'from api to provider' do
      before do
        get_via_redirect '/bong/facebook', {
          auth_origin_url: @redirect_url
        }

        @user = assigns(:user)
      end

      test 'status should be success' do
        assert_equal 200, response.status
      end

      test 'request should determine the correct resource_class' do
        assert_equal 'Mang', request.env['omniauth.params']['resource_class']
      end

      test 'request should pass correct redirect_url' do
        assert_equal @redirect_url, request.env['omniauth.params']['auth_origin_url']
      end

      test 'user should have been created' do
        assert @user
      end

      test 'user should be assigned info from provider' do
        assert_equal 'chongbong@aol.com', @user.email
      end

      test 'user should be of the correct class' do
        assert_equal Mang, @user.class
      end
    end
  end
end
