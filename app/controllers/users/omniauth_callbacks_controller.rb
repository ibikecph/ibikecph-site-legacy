class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    @user = User.find_for_facebook_oauth(request.env['omniauth.auth'])

    if @user.persisted?
      cookies.permanent.signed[:auth_token] = { value: @user.authentication_token, httponly: true }
      sign_in_and_redirect :user, @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      set_flash_message(:notice, :success, kind: 'Facebook')
      redirect_to new_user_registration_path
    end
  end

  def after_omniauth_failure_path_for(scope)
    '/users/sign_in'
  end

end
