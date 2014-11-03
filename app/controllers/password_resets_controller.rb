class PasswordResetsController < ApplicationController

  skip_before_filter :require_login
  before_filter :find_user_by_token, only: [:edit,:update]
  before_filter :check_expired, only: [:edit,:update]

  def new
    if current_user
      @email = current_user.email
      if @email.nil? && current_user.authentications.emails.count == 1
        @email = current_user.authentications.emails.first
      end

      if @email
        render :new_fixed
      else
        @emails = current_user.authentications.emails.map { |e| e.uid }
        render :new_select
      end
    else
      render :new_ask
    end
  end

  def create
    if current_user
      email = current_user.authentications.emails.active.first ||
              current_user.authentications.emails.find_by_uid(params[:email])
    else
      email = EmailAuthentication.find_by_uid params[:email]
    end
    if email
      if email.active?
        user = email.user
        user.send_password_reset
        path = current_user ? account_path : login_path
        redirect_to path, notice: t('password_resets.flash.instructions_sent', email: email.uid)
      else
        flash[:email] = email.uid
        redirect_to action: :unverified
      end
    else
      flash.now.alert = t('password_resets.flash.email_not_found', email: params[:email])
      render :new_ask
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
      logged_in account_path, notice: t('password_resets.flash.password_changed')
    else
      render :edit
    end
  end

  protected

  def find_user_by_token
    @user = User.find_by_password_reset_token params[:token] if params[:token]
    redirect_to new_password_reset_path, alert: t('password_resets.flash.invalid_link') unless @user
  end

  def check_expired
    if @user.password_reset_sent_at.blank? || @user.password_reset_sent_at < RESET_PASSWORD_PERIOD.ago
      redirect_to new_password_reset_path, alert: t('password_resets.flash.expired_link')
    end
  end

end
