class RegistrationsController < Devise::RegistrationsController

  before_filter :configure_permitted_parameters

  def after_update_path_for(resource)
    account_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(
      :name,
      :email_confirmation,
      :terms
      )
  end

end
