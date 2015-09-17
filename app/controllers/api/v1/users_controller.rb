class Api::V1::UsersController < Api::V1::BaseController

  load_and_authorize_resource :user

  def index
    @users = User.order('created_at desc')
  end

  def show
    @user = User.find_by id: params[:id]

    unless @user
      render status: 404,
             json: {
               success: false,
               info: t('users.flash.user_not_found'),
               errors: t('users.flash.user_not_found')
             }
    end
  end

  def destroy
    @user = User.find_by id: params[:id]

    if @user
      if @user.destroy_with_tracks params[:user][:password],
        render status: 200,
               json: {
                   success: true,
                   info: t('users.flash.deleted'),
                   data: {}
               }
      else
        render status: 401,
               json: {
                   success: false,
                   info: @user.errors,
                   data: @user.errors
               }
      end
    else
      render status: 404,
             json: {
                 success: false,
                 info: t('users.flash.user_not_found'),
                 errors: t('users.flash.user_not_found')
             }
    end
  end

  def change_password
    @user = User.find current_user.id

    if @user.update_and_generate_signature user_params
      sign_in(:user, @user, bypass: true)
      notice = if params[:user][:email] != @user.email
                 t('accounts.flash.activate_new_email')
               else
                 t('accounts.flash.password_changed')
               end

      render status: 200,
             json: {
                 success: true,
                 info: notice,
                 data: { signature: @user.signature }
             }
    else
      render status: 400,
             json: {
                 success: false,
                 info: {},
                 data: { errors: @user.errors.full_messages}
             }
    end
  end

  def add_password
    if current_user.encrypted_password.blank? && current_user.provider == 'facebook'
      if current_user.update_attributes password: params[:user][:password]
        signature = current_user.generate_signature params[:user][:password]
        render status: 200,
               json: {
                   success: true,
                   info: notice,
                   data: { signature: signature }
               }
      else
        render status: 400,
               json: {
                   success: false,
                   info: {},
                   data: { errors: @user.errors.full_messages}
               }
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
end
