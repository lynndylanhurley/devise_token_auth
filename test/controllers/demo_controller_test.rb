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
    end

    describe 'successful request' do
      before do
        request.headers['Authorization'] = @auth_header
        xhr :get, :members_only

        @resp_auth_header = response.headers['Authorization']
        @resp_token       = @resp_auth_header[/token=(.*?) /,1]
        @resp_client_id   = @resp_auth_header[/client=(.*?) /,1]
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

      it "should allow a new request to be made using new token" do
        request.headers['Authorization'] = @resp_auth_header
        xhr :get, :members_only

        assert_equal 200, response.status
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

    describe 'rapid succession of requests using same token' do
      before do
        request.headers['Authorization'] = @auth_header
        xhr :get, :members_only
        xhr :get, :members_only
      end

      it 'should allow both requests through' do
        assert_equal 200, response.status
      end
    end
  end
end
