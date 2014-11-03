class SessionsController < Devise::SessionsController

  def create
    @user = User.where(email: params[:user][:email])[0]

    if @user && !@user.confirmed?
      render :infopage
    else
      super
    end
  end

  def infopage

  end

end
