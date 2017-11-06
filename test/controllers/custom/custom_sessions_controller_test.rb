require 'test_helper'

class Custom::SessionsControllerTest < ActionController::TestCase
  describe Custom::SessionsController do
    before do
      @existing_user = users(:confirmed_email_user)
      @existing_user.skip_confirmation!
      @existing_user.save!
    end

    test 'yield resource to block on create success' do
      post :create,
           params: {
             email: @existing_user.email,
             password: 'secret123'
           }
      assert @controller.create_block_called?,
             'create failed to yield resource to provided block'
    end

    test 'yield resource to block on destroy success' do
      @auth_headers = @existing_user.create_new_auth_token
      request.headers.merge!(@auth_headers)
      delete :destroy, format: :json
      assert @controller.destroy_block_called?,
             'destroy failed to yield resource to provided block'
    end

    test 'render method override' do
      post :create,
           params: { email: @existing_user.email,
                     password: 'secret123' }
      @data = JSON.parse(response.body)
      assert_equal @data['custom'], 'foo'
    end
  end
end
