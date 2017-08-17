class RegistrationsController < Devise::RegistrationsController

  before_action :configure_permitted_parameters

  def after_update_path_for(resource)
    account_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name,:email_confirmation,:terms] )
  end

end
