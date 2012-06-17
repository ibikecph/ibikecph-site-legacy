class UsersController < ApplicationController
  
  before_filter :require_login, :only => [:edit,:update,:destroy]
  before_filter :find_user, :except => [:index,:new,:create]
  authorize_resource :only => [:show,:edit,:update,:destroy]
  
  def index
    @users = User.order('created_at desc').paginate :page => params[:page], :per_page => 100
  end
  
  def show
    @ideas = @user.ideas.
        includes(:user,:visualizations,:challenge).
        paginate :page => params[:page], :per_page => 20
  end
  
  def new
    @user = User.new
    @email = EmailAuthentication.new
    @user.authentications << @email
  end

  def create
    params[:user].delete(:role)     #never allow new users with a role
    @user = User.new params[:user]
    @email = EmailAuthentication.new params[:email_authentication]
    @user.authentications << @email
    if @user.save
      copy_return_to
      @email.send_activation
      auto_login @user
      logged_in account_path, :notice => "Account created. Welcome!"
    else
      @existing_user = User.find_by_name params[:user][:name]
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated User."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  
  def destroy
    @user.destroy
    flash[:notice] = "Successfully destroyed challenge."
    redirect_to :action => :index
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
