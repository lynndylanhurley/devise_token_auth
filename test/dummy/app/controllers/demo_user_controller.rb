class DemoUserController < ApplicationController
  before_action :authenticate_user!

  def members_only
    render json: {
      data: {
        message: "Welcome #{@user.name}",
        user: @user
      }
    }, status: 200
  end
end
