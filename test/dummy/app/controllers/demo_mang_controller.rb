class DemoMangController < ApplicationController
  before_action :authenticate_mang!

  def members_only
    render json: {
      data: {
        message: "Welcome #{@user.name}",
        user: @user
      }
    }, status: 200
  end
end
