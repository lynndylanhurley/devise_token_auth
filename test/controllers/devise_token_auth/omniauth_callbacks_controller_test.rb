require 'test_helper'
require 'mocha/test_unit'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class OmniauthTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  before do
    @redirect_url = "http://ng-token-auth.dev/"
  end

  describe 'success callback' do
    setup do
      OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
        :provider => 'facebook',
        :uid => '123545',
        :info => {
          name: 'chong',
          email: 'chongbong@aol.com'
        }
      })
    end

    test 'request should pass correct redirect_url' do
      get_success
      assert_equal @redirect_url, controller.send(:omniauth_params)['auth_origin_url']
    end

    test 'user should have been created' do
      get_success
      assert @resource
    end

    test 'user should be assigned info from provider' do
      get_success
      assert_equal 'chongbong@aol.com', @resource.email
    end

    test 'user should be assigned token' do
      get_success
      client_id = controller.auth_params[:client_id]
      token = controller.auth_params[:auth_token]
      expiry = controller.auth_params[:expiry]

      # the expiry should have been set
      assert_equal expiry, @resource.tokens[client_id][:expiry]
      # the token sent down to the client should now be valid
      assert @resource.valid_token?(token, client_id)
    end

    test 'session vars have been cleared' do
      get_success
      refute request.session['dta.omniauth.auth']
      refute request.session['dta.omniauth.params']
    end

    test 'sign_in was called' do
      User.any_instance.expects(:sign_in)
      get_success
    end

    test 'should be redirected via valid url' do
      get_success
      assert_equal 'http://www.example.com/auth/facebook/callback', request.original_url
    end

    describe 'with default user model' do
      before do
        get_success
      end
      test 'request should determine the correct resource_class' do
        assert_equal 'User', controller.send(:omniauth_params)['resource_class']
      end

      test 'user should be of the correct class' do
        assert_equal User, @resource.class
      end
    end

    describe 'with alternate user model' do
      before do
        get_via_redirect '/mangs/facebook', {
          auth_origin_url: @redirect_url,
          omniauth_window_type: 'newWindow'
        }
        assert_equal 200, response.status
        @resource = assigns(:resource)
      end
      test 'request should determine the correct resource_class' do
        assert_equal 'Mang', controller.send(:omniauth_params)['resource_class']
      end
        test 'user should be of the correct class' do
        assert_equal Mang, @resource.class
      end
    end

    describe 'pass additional params' do
      before do
        @fav_color = 'alizarin crimson'
        @unpermitted_param = "M. Bison"
        get_via_redirect '/auth/facebook', {
          auth_origin_url: @redirect_url,
          favorite_color: @fav_color,
          name: @unpermitted_param,
          omniauth_window_type: 'newWindow'
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

    describe "oauth registration attr" do
      after do
        User.any_instance.unstub(:new_record?)
      end

      describe 'with new user' do
        before do
          User.any_instance.expects(:new_record?).returns(true).at_least_once
        end

        test 'response contains oauth_registration attr' do

          get_via_redirect '/auth/facebook', {
            auth_origin_url: @redirect_url,
            omniauth_window_type: 'newWindow'
          }

          assert_equal true, controller.auth_params[:oauth_registration]
        end
      end

      describe 'with existing user' do
        before do
          User.any_instance.expects(:new_record?).returns(false).at_least_once
        end

        test 'response does not contain oauth_registration attr' do

          get_via_redirect '/auth/facebook', {
            auth_origin_url: @redirect_url,
            omniauth_window_type: 'newWindow'
          }

          assert_equal false, controller.auth_params.key?(:oauth_registration)
        end

      end

    end

    describe 'using namespaces' do
      before do
        get_via_redirect '/api/v1/auth/facebook', {
          auth_origin_url: @redirect_url,
          omniauth_window_type: 'newWindow'
        }

        @resource = assigns(:resource)
      end

      test 'request is successful' do
        assert_equal 200, response.status
      end

      test 'user should have been created' do
        assert @resource
      end

      test 'user should be of the correct class' do
        assert_equal User, @resource.class
      end
    end

    describe 'with omniauth_window_type=inAppBrowser' do
      test 'response contains all expected data' do
        get_success(omniauth_window_type: 'inAppBrowser')
        assert_expected_data_in_new_window
      end

    end

    describe 'with omniauth_window_type=newWindow' do
      test 'response contains all expected data' do
        get_success(omniauth_window_type: 'newWindow')
        assert_expected_data_in_new_window
      end
    end

    def assert_expected_data_in_new_window
      data_json = @response.body.match(/var data \= (.+)\;/)[1]
      data = ActiveSupport::JSON.decode(data_json)
      expected_data = @resource.as_json.merge(controller.auth_params.as_json)
      expected_data = ActiveSupport::JSON.decode(expected_data.to_json)
      assert_equal(expected_data.merge("message" => "deliverCredentials"), data)
    end

    describe 'with omniauth_window_type=sameWindow' do
      test 'redirects to auth_origin_url with all expected query params' do
        get_via_redirect '/auth/facebook', {
          auth_origin_url: '/auth_origin',
          omniauth_window_type: 'sameWindow'
        }
        assert_equal 200, response.status

        # We have been forwarded to a url with all the expected
        # data in the query params.

        # Assert that a uid was passed along.  We have to assume
        # that the rest of the values were as well, as we don't
        # have access to @resource in this test anymore
        assert(uid = controller.params['uid'], "No uid found")

        # check that all the auth stuff is there
        [:auth_token, :client_id, :uid, :expiry, :config].each do |key|
          assert(controller.params.key?(key), "No value for #{key.inspect}")
        end
      end
    end

    def get_success(params = {})
      get_via_redirect '/auth/facebook', {
        auth_origin_url: @redirect_url,
        omniauth_window_type: 'newWindow'
      }.merge(params)
      assert_equal 200, response.status
      @resource = assigns(:resource)
    end
  end

  describe 'failure callback' do
    setup do
      OmniAuth.config.mock_auth[:facebook] = :invalid_credentials
      OmniAuth.config.on_failure = Proc.new { |env|
        OmniAuth::FailureEndpoint.new(env).redirect_to_failure
      }
    end

    test 'renders expected data' do
      get_via_redirect '/auth/facebook', {
        auth_origin_url: @redirect_url,
        omniauth_window_type: 'newWindow'
      }
      assert_equal 200, response.status

      data_json = @response.body.match(/var data \= (.+)\;/)[1]
      data = ActiveSupport::JSON.decode(data_json)

      assert_equal({"error"=>"invalid_credentials", "message"=>"authFailure"}, data)
    end

    test 'renders something with no auth_origin_url' do
      get_via_redirect '/auth/facebook'
      assert_equal 200, response.status
      assert_select "body", "invalid_credentials"
    end
  end

  describe 'User with only :database_authenticatable and :registerable included' do
    test 'OnlyEmailUser should not be able to use OAuth' do
      assert_raises(ActionController::RoutingError) {
        get_via_redirect '/only_email_auth/facebook', {
          auth_origin_url: @redirect_url
        }
      }
    end
  end

  describe 'Using redirect_whitelist' do
    before do
      @user_email = 'slemp.diggler@sillybandz.gov'
      OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
        provider: 'facebook',
        uid: '123545',
        info: {
          name: 'chong',
          email: @user_email
        }
      )
      @good_redirect_url = Faker::Internet.url
      @bad_redirect_url = Faker::Internet.url
      DeviseTokenAuth.redirect_whitelist = [@good_redirect_url]
    end

    teardown do
      DeviseTokenAuth.redirect_whitelist = nil
    end

    test 'request using non-whitelisted redirect fail' do
      get_via_redirect '/auth/facebook',
                       auth_origin_url: @bad_redirect_url,
                       omniauth_window_type: 'newWindow'

      data_json = @response.body.match(/var data \= (.+)\;/)[1]
      data = ActiveSupport::JSON.decode(data_json)
      assert_equal "Redirect to '#{@bad_redirect_url}' not allowed.",
                   data['error']
    end

    test 'request to whitelisted redirect should succeed' do
      get_via_redirect '/auth/facebook',
                       auth_origin_url: @good_redirect_url,
                       omniauth_window_type: 'newWindow'

      data_json = @response.body.match(/var data \= (.+)\;/)[1]
      data = ActiveSupport::JSON.decode(data_json)
      assert_equal @user_email, data['email']
    end

    test 'should support wildcards' do
      DeviseTokenAuth.redirect_whitelist = ["#{@good_redirect_url[0..8]}*"]
      get_via_redirect '/auth/facebook',
                       auth_origin_url: @good_redirect_url,
                       omniauth_window_type: 'newWindow'

      data_json = @response.body.match(/var data \= (.+)\;/)[1]
      data = ActiveSupport::JSON.decode(data_json)
      assert_equal @user_email, data['email']
    end

  end
end
