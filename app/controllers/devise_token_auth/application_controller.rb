module DeviseTokenAuth
  class ApplicationController < ActionController::Base
    include DeviseTokenAuth::Concerns::SetUserByToken
    prepend_before_action :set_user_by_token
  end
end
