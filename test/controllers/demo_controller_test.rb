require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DemoControllerTest < ActionController::TestCase
  describe DemoController, "Token access" do
    setup do
      @routes = Dummy::Application.routes
    end

    before do
      @user = users(:confirmed_email_user)
      @user.skip_confirmation!
      @user.save!

      @auth_header = @user.create_new_auth_token

      @token       = @auth_header[/token=(.*?) /,1]
      @client_id   = @auth_header[/client=(.*?) /,1]
      @expiry      = @auth_header[/expiry=(.*?) /,1]
    end

    describe 'successful request' do
      before do
        # ensure that request is not treated as batch request
        age_token(@user, @client_id)

        request.headers['Authorization'] = @auth_header
        xhr :get, :members_only

        @resp_auth_header = response.headers['Authorization']
        @resp_token       = @resp_auth_header[/token=(.*?) /,1]
        @resp_client_id   = @resp_auth_header[/client=(.*?) /,1]
        @resp_expiry      = @resp_auth_header[/expiry=(.*?) /,1]
        @resp_uid         = @resp_auth_header[/uid=(.*?)$/,1]
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

      describe 'succesive requests' do
        before do
          @user.reload
          # ensure that request is not treated as batch request
          age_token(@user, @client_id)

          request.headers['Authorization'] = @resp_auth_header

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
        request.headers['Authorization'] = "token=bogus client=#{@client_id} uid=#{@user.uid}"
        xhr :get, :members_only
      end

      it 'should not return any auth headers' do
        refute response.headers['Authorization']
      end

      it 'should return error: unauthorized status' do
        assert_equal 401, response.status
      end
    end

    describe 'batch requests' do
      describe 'success' do
        before do
          request.headers['Authorization'] = @auth_header
          xhr :get, :members_only

          @first_is_batch_request = assigns(:is_batch_request)
          @first_user = assigns(:user)
          @first_auth_headers = response.headers['Authorization']

          request.headers['Authorization'] = @auth_header
          xhr :get, :members_only

          @second_is_batch_request = assigns(:is_batch_request)
          @second_user = assigns(:user)
          @second_auth_headers = response.headers['Authorization']
        end

        it 'should allow both requests through' do
          assert_equal 200, response.status
        end

        it 'should return the same auth headers for both requests' do
          assert_equal @first_auth_headers, @second_auth_headers
        end
      end

      describe 'time out' do
        before do
          @user.reload
          age_token(@user, @client_id)

          request.headers['Authorization'] = @auth_header
          xhr :get, :members_only

          @first_is_batch_request = assigns(:is_batch_request)
          @first_user = assigns(:user).dup
          @first_auth_headers = response.headers['Authorization'].clone
          @first_response_status = response.status

          @user.reload
          age_token(@user, @client_id)

          # use expired auth header
          request.headers['Authorization'] = @auth_header
          xhr :get, :members_only

          @second_is_batch_request = assigns(:is_batch_request)
          @second_user = assigns(:user)
          @second_auth_headers = response.headers['Authorization']
          @second_response_status = response.status
        end

        it 'should allow the first request through' do
          assert_equal 200, @first_response_status
        end

        it 'should not allow the second request through' do
          assert_equal 401, @second_response_status
        end

        it 'should return auth headers from the first request' do
          assert @first_auth_headers
        end

        it 'should not return auth headers from the second request' do
          refute @second_auth_headers
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
end
