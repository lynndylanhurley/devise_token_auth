class AuthOriginController < ApplicationController
  def redirected
    render :nothing => true
  end
end