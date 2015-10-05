class UsersController < ApplicationController

  before_filter :authenticate_user!, except: [:new, :create, :show]
  load_and_authorize_resource

  def index
    @users = User.order('created_at desc').paginate page: params[:page], per_page: 100
  end

  def show
  end

  def new
    @user = User.new
    @email = EmailAuthentication.new
    @user.authentications << @email
  end

  def create
    return unless user_params # && params[:user].is_a?(Hash)

    @user = User.new(user_params)
    @email = EmailAuthentication.new params[:email_authentication]
    @user.authentications << @email

    if @user.save
      copy_return_to
      @email.send_activation
      redirect_to activating_account_path
    # auto_login @user
    # logged_in account_path, notice: "Account created. Welcome!"
    else
      @existing_user = User.find_by_name params[:user][:name]
      render action: 'new'
    end
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
