require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DemoGroupControllerTest < ActionDispatch::IntegrationTest
  describe DemoGroupController do
    describe "Token access" do
      before do
        # user
        @user = users(:confirmed_email_user)
        @user.skip_confirmation!
        @user.save!

        @user_auth_headers = @user.create_new_auth_token

        @user_token     = @user_auth_headers['access-token']
        @user_client_id = @user_auth_headers['client']
        @user_expiry    = @user_auth_headers['expiry']

        # mang
        @mang = mangs(:confirmed_email_user)
        @mang.skip_confirmation!
        @mang.save!

        @mang_auth_headers = @mang.create_new_auth_token

        @mang_token     = @mang_auth_headers['access-token']
        @mang_client_id = @mang_auth_headers['client']
        @mang_expiry    = @mang_auth_headers['expiry']
      end

      describe 'user access' do
        before do
          # ensure that request is not treated as batch request
          age_token(@user, @user_client_id)

          get '/demo/members_only_group', {}, @user_auth_headers

          @resp_token       = response.headers['access-token']
          @resp_client_id   = response.headers['client']
          @resp_expiry      = response.headers['expiry']
          @resp_uid         = response.headers['uid']
        end

        test 'request is successful' do
          assert_equal 200, response.status
        end

        describe 'devise mappings' do
          it 'should define current_user' do
            assert_equal @user, @controller.current_user
          end

          it 'should define user_signed_in?' do
            assert @controller.user_signed_in?
          end

          it 'should not define current_mang' do
            refute_equal @user, @controller.current_mang
          end

          it 'should define current_member' do
            assert_equal @user, @controller.current_member
          end

          it 'should define current_members' do
            assert @controller.current_members.include? @user
          end

          it 'should define member_signed_in?' do
            assert @controller.current_members.include? @user
          end
        end
      end

      describe 'mang access' do
        before do
          # ensure that request is not treated as batch request
          age_token(@mang, @mang_client_id)

          get '/demo/members_only_group', {}, @mang_auth_headers

          @resp_token       = response.headers['access-token']
          @resp_client_id   = response.headers['client']
          @resp_expiry      = response.headers['expiry']
          @resp_uid         = response.headers['uid']
        end

        test 'request is successful' do
          assert_equal 200, response.status
        end

        describe 'devise mappings' do
          it 'should define current_mang' do
            assert_equal @mang, @controller.current_mang
          end

          it 'should define mang_signed_in?' do
            assert @controller.mang_signed_in?
          end

          it 'should not define current_mang' do
            refute_equal @mang, @controller.current_user
          end

          it 'should define current_member' do
            assert_equal @mang, @controller.current_member
          end

          it 'should define current_members' do
            assert @controller.current_members.include? @mang
          end

          it 'should define member_signed_in?' do
            assert @controller.current_members.include? @mang
          end
        end
      end
    end
  end
end

