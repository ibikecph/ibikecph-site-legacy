class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:new, :create, :show]
  load_and_authorize_resource

  def index
    @users = User.order('created_at desc').paginate page: params[:page], per_page: 100
  end

  def show
  end

  private

  def user_params
    params.require(:user).permit(
       :name,
       :about,
       :email,
       :email_confirmation,
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

  def warn_about_existing_name
    user = User.find_by_name @user.name
    if user
      @name = @auth['info']['name']
      render :existing_name
    end
  end

  def find_user
    @user = User.find params[:id]
  end

end
