class Api::V1::UsersController < Api::V1::BaseController

  load_and_authorize_resource :user

  def index
    @users = User.order('created_at desc')
  end

  def show
    @user = User.find_by id: params[:id]
  end

  def destroy
    @user = User.find_by id: params[:id]

    if @user.encrypted_password.present?
      if @user.destroy_with_tracks params[:user][:password]
        success t('users.flash.deleted')
      else
        failure @user
      end
    elsif @user.destroy
      success t('users.flash.deleted')
    end
  end

  def change_password
    @user = User.find current_user.id

    if @user.update_and_generate_signature user_params
      sign_in(:user, @user, bypass: true)

      success notice, signature: @user.signature
    else
      failure @user
    end
  end

  def add_password
    if current_user.encrypted_password.blank? && current_user.provider == 'facebook'
      if current_user.update_attributes password: params[:user][:password]
        signature = current_user.generate_signature params[:user][:password]

        success nil, signature: signature
      else
        failure current_user
      end
    end
  end

  def has_password
    has_password = false
    has_password = true if current_user.encrypted_password.present?

    render status: 200, json: {has_password: has_password}
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
        :account_source
    )
  end

  def notice
    self.unconfirmed_email.present? ?
        t('accounts.flash.activate_new_email') :
        t('accounts.flash.password_changed')
  end

  def record_not_found
    super t('api.resources.user')
  end
end
