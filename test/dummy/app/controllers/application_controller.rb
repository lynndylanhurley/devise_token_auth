# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    permitted_parameters = devise_parameter_sanitizer.instance_values['permitted']
    permitted_parameters[:sign_up] << :operating_thetan
    permitted_parameters[:sign_up] << :favorite_color
    permitted_parameters[:account_update] << :operating_thetan
    permitted_parameters[:account_update] << :favorite_color
    permitted_parameters[:account_update] << :current_password
  end
end
