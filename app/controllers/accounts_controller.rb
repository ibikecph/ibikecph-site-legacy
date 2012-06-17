class AccountsController < ApplicationController
  
  before_filter :require_login, :except => [:activating,:unverified_email,:new_activation,
      :create_activation,:activate,:resend_activation,:verify_email,:existing]
  
  before_filter :check_can_set_password, :only => [:new_password, :create_password]
  before_filter :find_email_authentication_by_token, :only => [:verify_email]
    
  layout :choose_layout
  
  def show
    @has_password = current_user.has_password?
    @has_email = current_user.authentications.emails.active.any?
  end
  
  def logins
    @email_auths = current_user.authentications.emails
    @oauth_auths = current_user.authentications.oauths
    @can_add_email = current_user.authentications.emails.count < MAX_EMAILS
    @can_remove_email = current_user.authentications.emails.active.count > 1
    @can_remove_oauth = current_user.authentications.emails.active.count >= 1 || current_user.authentications.oauths.active.count > 1
    @has_password = current_user.has_password?
    @has_email = current_user.authentications.emails.active.any?
    @has_unverified_email = current_user.authentications.emails.unverified.any?
  end
  
  def activating
  end
  
  def welcome
  end
  
  def new_activation
  end
  
  def create_activation
    authentication = Authentication.find_by_provider_and_uid 'email', params[:email]
    if authentication
      authentication.send_activation
      redirect_to activating_account_path, :notice => "Activation email sent to #{authentication.uid}."
    else
      flash.now.alert = "Email not found."
      render :new_activation
    end
  end
  
  def edit_password
  end
  
  def update_password
    if current_user.authenticate params[:password]
      if current_user.update_attributes params[:user]
        current_user.password_reset_token = nil
        current_user.save!
        redirect_to account_path, :notice => "Password changed."
      else
        render :edit_password
      end
    else
      flash.now.alert = "Current password was incorrect."
      render :edit_password
    end
  end
  
  def edit
  end
  
  def update
    if current_user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated profile."
      redirect_to account_path
    else
      render :action => :edit
    end
  end
  
  def destroy_oath_login
    @auth = current_user.authentications.oauths.find params[:id]
    if @auth.active? && current_user.authentications.active.count == 1
      redirect_to account_path, :alert => "Cannot remove the last active login."
    else
      @auth.destroy
      redirect_to account_path
    end
  end
  
  def notifications
    @has_email = current_user.authentications.emails.active.any?
  end
  
  def update_notifications
    if current_user.update_attributes(params[:user])
      flash[:notice] = "Notification settings updated."
    end
    redirect_to notifications_account_path
  end
  
  private
  
  def choose_layout
    current_user.present? ? "account" : "application"
  end

end
