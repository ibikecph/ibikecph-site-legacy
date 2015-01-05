class Api::V1::UsersController < Api::V1::BaseController

  before_filter :check_auth, if: Proc.new { |c| c.request.format == 'application/json' }
  load_and_authorize_resource :user, find_by: :find_by_id

  def index
    @users = User.order('created_at desc')
  end

  def show
    @user = User.find params[:id]
  rescue ActiveRecord::RecordNotFound

    render status: 404,
           json: {
             success: false,
             info: t('users.flash.user_not_found'),
             errors: t('users.flash.user_not_found')
           }
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy

    render status: 200,
           json: {
             success: true,
             info: t('users.flash.deleted'),
             data: {}
           }
  end

  private

  def find_user
    @user = User.find params[:id]
  end

end
