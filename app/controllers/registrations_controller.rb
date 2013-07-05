class RegistrationsController < Devise::RegistrationsController
  def after_update_path_for(resource)
    account_path
  end
end