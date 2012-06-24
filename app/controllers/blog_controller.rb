class BlogController < ApplicationController
  
  before_filter :find_blog_entry, :except => [:index,:archive,:new,:create]
  before_filter :authorize, :except => [:index,:show,:archive]
  before_filter :find_blog_entries, :only => [:index,:show]
  
  def index
  end
  
  def archive
    @blog_entries = BlogEntry.latest
  end
  
  def show
    @blog_entry = BlogEntry.find params[:id]
    @comments = @blog_entry.comments
  end

  def new
    @blog_entry = BlogEntry.new
  end
  
  def create
    @blog_entry = current_user.blog_entries.build params[:blog_entry]
    if @blog_entry.save
      Publisher.publish @blog_entry
      flash[:notice] = t('blog.flash.created')
      redirect_to @blog_entry
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @blog_entry.update_attributes(params[:blog_entry])
      flash[:notice] = t('blog.flash.updated')
      redirect_to @blog_entry
    else
      render :edit
    end
  end
  
  def destroy
    @blog_entry.destroy
    flash[:notice] = t('blog.flash.deleted')
    redirect_to blog_entry_index_path
  end
  
  private
  
  def find_blog_entry
    @blog_entry = BlogEntry.find params[:id]
  end
  
  def authorize
    authorize! :manage, @blog_entry || BlogEntry
  end
  
  def find_blog_entries
    @blog_entries = BlogEntry.latest.limit(20)
  end
  
end

