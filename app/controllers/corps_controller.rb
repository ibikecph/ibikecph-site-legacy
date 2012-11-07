class CorpsController < ApplicationController

  skip_before_filter :require_login, :only => [:index, :show]
  
  def index
    @users = User.where(:tester => true).order('name asc').paginate :page => params[:page], :per_page => 20
  end
  
  def show
    @user = User.find params[:id]
    @issues = @user.issues.lastest.paginate :page => params[:page], :per_page => 50
    
  end
  
  def join
    if current_user.tester
      flash[:notice] = t('corps.flash.already_joined')
    else
      current_user.update_attributes :tester => true
      flash[:notice] = t('corps.flash.joined')
    end
    redirect_to corps_path
  end
  
  def leave
    if !current_user.tester
      flash[:notice] = t('corps.flash.already_left')
    else
      current_user.update_attributes :tester => false
      flash[:notice] = t('corps.flash.left')
    end
    redirect_to corps_path
  end
  
end
