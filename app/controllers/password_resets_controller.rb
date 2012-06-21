class PasswordResetsController < ApplicationController
  
  skip_before_filter :require_login
  before_filter :find_user_by_token, :only => [:edit,:update]
  before_filter :check_expired, :only => [:edit,:update]
    
  def new
    if current_user
      if current_user.has_active_email?
        @emails = current_user.authentications.emails.active.map { |e| e.uid }
        render :new_logged_in
      else
        redirect_to account_path, :alert => "Cannot reset password without a verified email."
      end
    end
  end
  
  def create
    if current_user
      email = current_user.authentications.emails.active.first
    else
      email = EmailAuthentication.find_by_uid params[:email]
    end
    if email
      path = current_user ? account_path : login_path
      if email.active?
        user = email.user
        user.send_password_reset
        redirect_to path, :notice => "Instructions for resetting your password has been emailed to #{email.uid}."
      else
        flash[:email] = email.uid
        redirect_to :action => :unverified
      end
    else
      flash.now.alert = "Email not found."
      render :new
    end
  end
  
  def edit
  end

  def update
    if @user.update_attributes params[:user]
      @user.password_reset_token = nil
      @user.save!
      auto_login @user
      copy_return_to
      logged_in account_path, :notice => "Password has been changed."
    else
      render :edit
    end
  end
  
  protected
  
  def find_user_by_token
    @user = User.find_by_password_reset_token params[:token] if params[:token]
    redirect_to new_password_reset_path, :alert => "Password reset invalid." unless @user
  end
  
  def check_expired
    if @user.password_reset_sent_at.blank? || @user.password_reset_sent_at < RESET_PASSWORD_PERIOD.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    end
  end
  
end