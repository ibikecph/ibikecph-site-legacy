class PasswordsController < Devise::PasswordsController

def create
  @user = User.find_by_email(params[:user][:email])
  if @user and @user.facebook_user?
    flash[:notice] = t('password_resets.flash.fb_user_AD')
      redirect_to new_session_path(resource_name)
  else
    super
  end
  
end

end