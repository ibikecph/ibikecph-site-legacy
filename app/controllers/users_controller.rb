class UsersController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:new,:create,:show]
  load_and_authorize_resource
  
  def index
    @users = User.order('created_at desc').paginate :page => params[:page], :per_page => 100
  end
  
  def show
  end
  
  def new
    @user = User.new
    @email = EmailAuthentication.new
    @user.authentications << @email
  end

  def create
    return unless params[:user] && params[:user].is_a?(Hash)
    params[:user].delete(:role)     #never allow new users with a role
    @user = User.new params[:user]
    @email = EmailAuthentication.new params[:email_authentication]
    @user.authentications << @email
    if @user.save
      copy_return_to
      @email.send_activation
      redirect_to activating_account_path
      #auto_login @user
      #logged_in account_path, :notice => "Account created. Welcome!"
    else
      @existing_user = User.find_by_name params[:user][:name]
      render :action => 'new'
    end
  end
  
  private
    
  def warn_about_existing_name
    user = User.find_by_name @user.name
    if user
      @name = @auth['info']['name']
      render :existing_name
    end
  end
  
  private
  
  def find_user
    @user = User.find params[:id]
  end
  
end
