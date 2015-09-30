class SessionsController < Devise::SessionsController
  def create
    @user = User.where(email: params[:user][:email])[0]

    if @user && !@user.confirmed?
      render :infopage
    else
      super
      cookies.permanent.signed[:auth_token] = {
          value:    @user.authentication_token,
          httponly: true
      }
    end
  end

  def destroy
    super
    cookies.delete :auth_token
  end

  def infopage

  end

end
