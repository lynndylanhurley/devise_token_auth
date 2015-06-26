require 'test_helper'

class Custom::ConfirmationsControllerTest < ActionController::TestCase

  describe Custom::ConfirmationsController do

    before do
      @redirect_url = Faker::Internet.url
      @new_user = users(:unconfirmed_email_user)
      @new_user.send_confirmation_instructions({
        redirect_url: @redirect_url
      })
      @mail          = ActionMailer::Base.deliveries.last
      @token         = @mail.body.match(/confirmation_token=([^&]*)&/)[1]
      @client_config = @mail.body.match(/config=([^&]*)&/)[1]

      get :show, {confirmation_token: @token, redirect_url: @redirect_url}
    end

    test "yield resource to block on show success" do
      assert @controller.show_block_called?, "show failed to yield resource to provided block"
    end

  end

end
