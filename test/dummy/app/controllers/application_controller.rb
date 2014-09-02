class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?

  respond_to :json

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :operating_thetan
    devise_parameter_sanitizer.for(:sign_up) << :favorite_color
    devise_parameter_sanitizer.for(:account_update) << :operating_thetan
    devise_parameter_sanitizer.for(:account_update) << :favorite_color
  end
end
