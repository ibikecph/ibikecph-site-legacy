class EmailsController < ApplicationController
  
  #FIXME to be able to use distance_of_time_in_words when construction flash messages.
  #since it's a view helper, it's not standard to use it here in the controller.
   
  include ActionView::Helpers::DateHelper

  before_filter :require_login, :except => [:unverified,:verify,:new_verification,:create_verification] 
  before_filter :find_authentication, :except => [:new,:create,:unverified,:verify,:new_verification,:create_verification]
  before_filter :find_authentication_by_token, :only => [:verify]
  
  def unverified
  end
  
  def new
    @auth = EmailAuthentication.new
    @auth.user = current_user
    unless current_user.has_password?
      render :new_password
    end
  end
  
  def create
    has_password = current_user.has_password?

    @auth = current_user.authentications.build params[:email_authentication].merge(:type => 'EmailAuthentication')

    unless has_password
      current_user.password = params[:user][:password]
      current_user.password_confirmation = params[:user][:password_confirmation]
      current_user.password_reset_token = nil
    end

    if current_user.save
      @auth.send_verify
      redirect_to account_path, :notice => "Verification instructions sent to #{@auth.uid}."
    else
      if has_password
        render :new
      else
        render :new_password
      end
    end
  end
  
  
  def new_verification
  end

  def create_verification
    @auth = EmailAuthentication.find_by_uid params[:email]
    if @auth
      if @auth.active?
        redirect_to login_path, :alert => t('emails.flash.already_verified', :email => @auth.uid)
      else
        if @auth.token_created_at > RESEND_WAIT.ago
          redirect_to verify_emails_path(:email => @auth.uid), :alert => "Verification email can only be sent once each #{distance_of_time_in_words RESEND_WAIT}. Please wait a while and try again."
        else
          @auth.send_verify
          redirect_to login_path, :notice => t('emails.flash.verification_sent', :email => @auth.uid)
        end
      end
    else
      flash.now.alert = t('emails.flash.not_found', :email => params[:email])
      render :new_verification
    end
  end

  def verify
    if @user.has_password?
      welcome = @user.authentications.active.empty?
      activate_email
      if welcome
        copy_return_to
        logged_in welcome_account_path, :notice => t('emails.flash.verified', :email => @auth.uid)
      else
        redirect_to account_path, :notice => t('emails.flash.verified', :email => @auth.uid)
      end
    else
      render :new_password
    end
  end

  
  private
  
  def find_authentication
    @auth = EmailAuthentication.find_by_id! params[:id]
  end
  
  def find_authentication_by_token
    if params[:token]
      @auth = Authentication.find_by_provider_and_token 'email', params[:token]
      if @auth
        if @auth.token_created_at == nil || @auth.token_created_at < VALID_TOKEN_PERIOD.ago
          flash[:alert] = t('emails.flash.verification_expired')
        end
        @user = @auth.user
        return
      end
    end
    redirect_to current_user ? account_path : root_path
  end
  
  def activate_email
    @auth.activate
    @auth.save!
    @user.cleanup_emails @auth
    auto_login @user
  end
  
  def create_dont_set_password
    if @auth.save
      @auth.send_verify
      redirect_to account_path, :notice => t('emails.flash.verification_sent', :email => @auth.uid)
    else
      render :new
    end
  end
  
  def create_set_password
    if current_user.update_attributes params[:user].merge({:password_reset_token => nil})
      redirect_to account_path, :notice => t('emails.flash.verified_with_password', :email => @auth.uid)
    else
      render :new_password
    end
  end
end
