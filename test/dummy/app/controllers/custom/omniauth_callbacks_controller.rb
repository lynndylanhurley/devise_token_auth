class Custom::OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController

  def omniauth_success
    super do |resource|
      @omniauth_success_block_called = true
    end
  end

  def omniauth_success_block_called?
    @omniauth_success_block_called == true
  end

end
