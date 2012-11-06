class ThemesController < ApplicationController

  skip_before_filter :require_login, :only => [:index,:show,:tag]
  before_filter :find_theme, :only => [:show,:edit,:update,:destroy]
  authorize_resource :class => "Theme"
  
  def index
    @themes = Theme.latest.paginate :page => params[:page], :per_page => 10
  end
  
  def show
    @issues = @theme.issues.lastest.includes(:user).paginate :page => params[:page], :per_page => 50
    @themes = Theme.all
    @most_commented = @theme.issues.most_commented.includes(:user).limit(7)
  end
  
  def new
    @theme = Theme.new
  end
  
  def create
    @theme = current_user.themes.build params[:theme]
    if @theme.save
      Publisher.publish @theme
      flash[:notice] = t('themes.flash.created')
      redirect_to @theme
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @theme.update_attributes(params[:theme])
      flash[:notice] = t('themes.flash.updated')
      redirect_to @theme
    else
      render :edit
    end
  end
  
  def destroy
    @theme.destroy
    flash[:notice] = t('themes.flash.destroyed')
    redirect_to themes_path
  end
  
  private
  
  def find_theme
    @theme = Theme.find params[:id]
  end
end
