class CorpsController < ApplicationController

  before_filter :authenticate_user!, :except =>  [:index, :show]
  before_filter :load_sidebar
  before_filter :find_users, :except => [:show]
  
  def index
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
    render :joined
  end
  
  def leave
    if !current_user.tester
      flash[:notice] = t('corps.flash.already_left')
    else
      current_user.update_attributes :tester => false
      flash[:notice] = t('corps.flash.left')
    end
    render :left
  end
  
  private

  def load_sidebar
    @most_commented = Issue.most_commented.includes(:user).limit(7)
    @popular_tags = Issue.tag_counts_on(:tags).order('count desc').limit(20)
  end  
  
  def find_users
    @users = User.where(:tester => true).order('name asc').paginate :page => params[:page], :per_page => 20
  end
  
end
