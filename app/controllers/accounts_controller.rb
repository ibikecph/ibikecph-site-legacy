class AccountsController < ApplicationController

  before_filter :authenticate_user!, except: [
                  :activating,
                  :unverified_email,
                  :new_activation,
                  :create_activation,
                  :activate,
                  :resend_activation,
                  :verify_email,
                  :existing
                ]

  # before_filter :check_can_set_password, only: [:new_password, :create_password]
  # before_filter :find_email_authentication_by_token, only: [:verify_email]

  def show
    # @has_password = current_user.has_password?
    # @has_email = current_user.authentications.emails.active.any?
  end

  def activating
  end

  def welcome
  end

  def edit_password
    @user = current_user
  end

  def update_password
    @user = User.find(current_user.id)

    if @user.update_with_password(params[:user])
      sign_in(:user, @user, bypass: true)

      # email changed
      notice = if params[:user][:email] != @user.email
                 t('accounts.flash.activate_new_email')
               else
                 t('accounts.flash.password_changed')
               end

      redirect_to account_path, notice: notice
    else
      render :edit_password
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(current_user.id)
    if @user.update_attributes(params[:user])
      flash[:notice] = t('accounts.flash.updated')
      redirect_to account_path
    else
      render action: edit
    end
  end

  def destroy_oath_login
    @auth = current_user.authentications.oauths.find params[:id]

    if @auth.active? && current_user.authentications.active.count == 1
      redirect_to account_path, alert: 'Cannot remove the last active login.'
    else
      @auth.destroy
      redirect_to account_path
    end
  end

  def settings
    # @has_email = current_user.authentications.emails.active.any?
  end

  def update_settings
    if current_user.update_attributes(params[:user])
      flash[:notice] = t('accounts.flash.settings_updated')
      redirect_to account_path
    else
      render :settings
    end
  end

end
