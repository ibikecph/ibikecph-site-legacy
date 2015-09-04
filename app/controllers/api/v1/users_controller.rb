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

    unless @user
      render status: 404,
             json: {
               success: false,
               info: t('users.flash.user_not_found'),
               errors: t('users.flash.user_not_found')
             }
    else
      @user.destroy

      render status: 200,
             json: {
               success: true,
               info: t('users.flash.deleted'),
               data: {}
             }
    end
  end

  def change_password
    @user = User.find(current_user.id)

    token = @user.change_password_and_token user_params

    if token
      sign_in(:user, @user, bypass: true)

      # email changed
      notice = if params[:user][:email] != @user.email
                 t('accounts.flash.activate_new_email')
               else
                 t('accounts.flash.password_changed')
               end

      render status: 200,
             json: {
                 success: true,
                 info: notice,
                 data: { signature: token.signature }
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
