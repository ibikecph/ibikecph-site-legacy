class Api::V1::UsersController < Api::V1::BaseController

  before_filter :check_auth, if: Proc.new { |c| c.request.format == 'application/json' }
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

end
