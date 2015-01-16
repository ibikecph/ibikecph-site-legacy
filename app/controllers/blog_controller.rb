class BlogController < ApplicationController

  before_filter :authenticate_user!, except: [:index, :archive, :show, :tag, :transition]
  before_filter :find_entry, only: [:show, :edit, :update, :destroy]
  authorize_resource class: 'BlogEntry', except: [:transition]
  before_filter :latest, only: [:show, :tag, :transition]
  before_filter :tag_cloud, only: [:index, :archive, :show, :tag, :transition]
  before_filter :check_return_path, only: :show

  def index
    @blog_entries = BlogEntry.news.latest.paginate page: params[:page], per_page: 10
  end

  def archive
    @blog_entries = BlogEntry.news.latest.paginate page: params[:page], per_page: 10
  end

  def show
    @comments = @blog_entry.comments
  end

  def transition
    redirect_to action: :index
  end

  def tag
    @blog_entries = BlogEntry.news.tagged_with(params[:tag]).latest.paginate page: params[:page], per_page: 10
  end

  def new
    @blog_entry = BlogEntry.new
  end

  def create
    @blog_entry = current_user.blog_entries.build blog_params

    if @blog_entry.save
      current_user.follow @blog_entry
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
    if @blog_entry.update_attributes blog_params
      flash[:notice] = t('blog.flash.updated')
      redirect_to @blog_entry
    else
      render :edit
    end
  end

  def destroy
    @blog_entry.destroy
    flash[:notice] = t('blog.flash.destroyed')
    redirect_to blog_entry_index_path
  end

  def feed
    @blog_entries = BlogEntry.news.latest
    respond_to do |format|
      format.rss { render layout: false }
    end
  end

  private

  def blog_params
    params.require(:blog_entry).permit(
      :title,
      :body,
      :tag_list,
      :category_list,
      :image,
      :remove_image,
      :image_cache,
      :sticky
    )
  end

  def find_entry
    @blog_entry = BlogEntry.find params[:id]
  end

  def latest
    @latest = BlogEntry.news.latest.limit(10)
  end

  def tag_cloud
    @tags = BlogEntry.news.tag_counts_on(:tags)
  end

  def check_return_path
    session.delete(:user_return_to) ? current_user : store_location
  end

end
