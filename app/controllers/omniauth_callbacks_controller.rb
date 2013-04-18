class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      #sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      sign_in(:user, @user)
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      redirect_to root_url
    else
      set_flash_message(:notice, :success, :kind => "Facebook")
      redirect_to root_url
    end
  end
end