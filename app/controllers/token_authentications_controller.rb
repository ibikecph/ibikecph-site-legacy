class TokenAuthenticationsController < ApplicationController
  
  def create
    @user = User.find_by_id(params[:user_id])
    @user.reset_authentication_token!
    redirect_to settings_account_path
  end

  def destroy
    @user = User.find_by_id(params[:id])
    @user.authentication_token = nil
    @user.save
    redirect_to settings_account_path
  end

end
