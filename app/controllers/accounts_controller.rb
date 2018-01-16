class AccountsController < ApplicationController

   before_action :authenticate_user!, except: [
                  :activating,
                  :unverified_email,
                  :new_activation,
                  :create_activation,
                  :activate,
                  :resend_activation,
                  :verify_email,
                  :existing
                ]

  #  before_action :check_can_set_password, only: [:new_password, :create_password]
  #  before_action :find_email_authentication_by_token, only: [:verify_email]

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

    if @user.update_and_generate_signature user_params
      sign_in(:user, @user, bypass: true)

      cookies.permanent.signed[:auth_token] = {
          value:    @user.authentication_token,
          httponly: true
      }
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
    if @user.update_attributes user_params
      flash[:notice] = t('accounts.flash.updated')
      redirect_to account_path
    else
      render action: :edit
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
    if current_user.update_attributes user_params
      flash[:notice] = t('accounts.flash.settings_updated')
      redirect_to account_path
    else
      render :settings
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :about,
      :email,
      :email_confirmation,
      :current_password,
      :password,
      :password_confirmation,
      :image,
      :image_path,
      :remove_image,
      :image_cache,
      :notify_by_email,
      :terms,
      :tester,
      :provider,
      :uid,
      :account_source,
      :email_confirmation
    )
  end

end
