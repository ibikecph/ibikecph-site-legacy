class BlogController < ApplicationController
  
  before_filter :find_blog_entry, :except => [:index,:archive,:new,:create]
  before_filter :authorize, :except => [:index,:show]
  before_filter :find_blog_entries, :only => [:index,:archive]
  
  def index
  end
  
  def archive
  end
  
  def show
    @blog_entry = BlogEntry.find params[:id]
    @comments = @blog_entry.comments
  end

  def new
    @blog_entry = BlogEntry.new
  end
  
  def create
    @blog_entry = BlogEntry.new params[:blog_entry]
    @blog_entry.user = current_user
    if @blog_entry.save
#      Publisher.publish_blog_entry @blog_entry
      flash[:notice] = "Successfully created blog entry."
      redirect_to @blog_entry
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @blog_entry.update_attributes(params[:blog_entry])
      flash[:notice] = "Successfully updated blog entry."
      redirect_to @blog_entry
    else
      render :edit
    end
  end
  
  def destroy
    @blog_entry.destroy
    flash[:notice] = "Successfully destroyed blog entry."
    redirect_to blog_entry_index_path
  end
  
  private
  
  def find_blog_entry
    @blog_entry = BlogEntry.find params[:id]
  end
  
  def authorize
    #authorize! :manage, @blog_entry || BlogEntry
  end
  
  def find_blog_entries
    @blog_entries = BlogEntry.all
  end
  
end

