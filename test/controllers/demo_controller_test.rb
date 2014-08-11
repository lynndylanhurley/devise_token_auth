require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DemoControllerTest < ActionController::TestCase
  describe DemoController do
    describe "Token access" do
      before do
        @user = users(:confirmed_email_user)
        @user.skip_confirmation!
        @user.save!

        @auth_headers = @user.create_new_auth_token

        @token     = @auth_headers['access-token']
        @client_id = @auth_headers['client']
        @expiry    = @auth_headers['expiry']
      end

      describe 'successful request' do
        before do
          # ensure that request is not treated as batch request
          age_token(@user, @client_id)

          request.headers.merge!(@auth_headers)
          xhr :get, :members_only

          @resp_token       = response.headers['access-token']
          @resp_client_id   = response.headers['client']
          @resp_expiry      = response.headers['expiry']
          @resp_uid         = response.headers['uid']
        end

        it 'should return success status' do
          assert_equal 200, response.status
        end

        it 'should receive new token after successful request' do
          refute_equal @token, @resp_token
        end

        it 'should preserve the client id from the first request' do
          assert_equal @client_id, @resp_client_id
        end

        it "should return the user's uid in the auth header" do
          assert_equal @user.uid, @resp_uid
        end

        it 'should not treat this request as a batch request' do
          refute assigns(:is_batch_request)
        end

        describe 'subsequent requests' do
          before do
            @user.reload
            # ensure that request is not treated as batch request
            age_token(@user, @client_id)

            request.headers['access-token'] = @resp_token

            xhr :get, :members_only
          end

          it 'should not treat this request as a batch request' do
            refute assigns(:is_batch_request)
          end

          it "should allow a new request to be made using new token" do
            assert_equal 200, response.status
          end
        end
      end

      describe 'failed request' do
        before do
          request.headers['access-token'] = "bogus"
          xhr :get, :members_only
        end

        it 'should not return any auth headers' do
          refute response.headers['access-token']
        end

        it 'should return error: unauthorized status' do
          assert_equal 401, response.status
        end
      end

      describe 'disable change_headers_on_each_request' do
        before do
          DeviseTokenAuth.change_headers_on_each_request = false
          @user.reload
          age_token(@user, @client_id)

          request.headers.merge!(@auth_headers)
          xhr :get, :members_only

          @first_is_batch_request = assigns(:is_batch_request)
          @first_user = assigns(:user).dup
          @first_access_token = response.headers['access-token']
          @first_response_status = response.status

          @user.reload
          age_token(@user, @client_id)

          # use expired auth header
          request.headers.merge!(@auth_headers)
          xhr :get, :members_only

          @second_is_batch_request = assigns(:is_batch_request)
          @second_user = assigns(:user)
          @second_access_token = response.headers['access-token']
          @second_response_status = response.status
        end

        after do
          DeviseTokenAuth.change_headers_on_each_request = true
        end

        it 'should allow the first request through' do
          assert_equal 200, @first_response_status
        end

        it 'should allow the second request through' do
          assert_equal 200, @second_response_status
        end

        it 'should return auth headers from the first request' do
          assert @first_access_token
        end

        it 'should return auth headers from the second request' do
          assert @second_access_token
        end

        it 'should define user during first request' do
          assert @first_user
        end

        it 'should define user during second request' do
          assert @second_user
        end
      end

      describe 'batch requests' do
        describe 'success' do
          before do
            request.headers.merge!(@auth_headers)
            xhr :get, :members_only

            @first_is_batch_request = assigns(:is_batch_request)
            @first_user = assigns(:user)
            @first_access_token = response.headers['access-token']

            request.headers.merge!(@auth_headers)
            xhr :get, :members_only

            @second_is_batch_request = assigns(:is_batch_request)
            @second_user = assigns(:user)
            @second_access_token = response.headers['access-token']
          end

          it 'should allow both requests through' do
            assert_equal 200, response.status
          end

          it 'should return the same auth headers for both requests' do
            assert_equal @first_access_token, @second_access_token
          end
        end

        describe 'time out' do
          before do
            @user.reload
            age_token(@user, @client_id)

            request.headers.merge!(@auth_headers)
            xhr :get, :members_only

            @first_is_batch_request = assigns(:is_batch_request)
            @first_user = assigns(:user).dup
            @first_access_token = response.headers['access-token']
            @first_response_status = response.status

            @user.reload
            age_token(@user, @client_id)

            # use expired auth header
            request.headers.merge!(@auth_headers)
            xhr :get, :members_only

            @second_is_batch_request = assigns(:is_batch_request)
            @second_user = assigns(:user)
            @second_access_token = response.headers['access-token']
            @second_response_status = response.status
          end

          it 'should allow the first request through' do
            assert_equal 200, @first_response_status
          end

          it 'should not allow the second request through' do
            assert_equal 401, @second_response_status
          end

          it 'should return auth headers from the first request' do
            assert @first_access_token
          end

          it 'should not return auth headers from the second request' do
            refute @second_access_token
          end

          it 'should define user during first request' do
            assert @first_user
          end

          it 'should not define user during second request' do
            refute @second_user
          end
        end
      end
    end

    # test with non-standard user class
    describe "Alternate user class" do
      setup do
        @request.env['devise.mapping'] = Devise.mappings[:mang]
      end

      teardown do
        @request.env['devise.mapping'] = Devise.mappings[:user]
      end

      before do
        @user = mangs(:confirmed_email_user)
        @user.skip_confirmation!
        @user.save!

        @auth_headers = @user.create_new_auth_token

        @token     = @auth_headers['access-token']
        @client_id = @auth_headers['client']
        @expiry    = @auth_headers['expiry']

        # ensure that request is not treated as batch request
        age_token(@user, @client_id)

        request.headers.merge!(@auth_headers)
        xhr :get, :members_only

        @resp_token       = response.headers['access-token']
        @resp_client_id   = response.headers['client']
        @resp_expiry      = response.headers['expiry']
        @resp_uid         = response.headers['uid']
      end

      it 'should return success status' do
        assert_equal 200, response.status
      end
    end
  end
end
