class IssuesController < ApplicationController
       
  skip_before_filter :require_login, :only => [:index,:all,:show,:tags,:labels,:search,:searched]
  load_and_authorize_resource :except => [:new_for_theme,:create_for_theme,:tags,:labels,:all,:search,:searched]
  skip_authorize_resource :only => [:all,:new_for_theme,:create_for_theme,:tags,:labels]
  #before_filter :find_vote, :only => [:show,:vote,:unvote]
  before_filter :load_sidebar, :only => [:index,:all,:tags,:labels,:show,:corps,:search,:searched]
  before_filter :find_popular_tags, :only => [:index,:show,:tags,:labels]

  def index
    @theme = Theme.latest.first
    if @theme
      @issues = @theme.issues.lastest.includes(:user).paginate :page => params[:page], :per_page => 50
    else
      all
    end
  end
  
  def all
    @issues = Issue.lastest.includes(:user).paginate :page => params[:page], :per_page => 30
  end
  
  def show
    #count_votes
    @comments = @issue.comments
    @related = @issue.find_related_tags.limit(20)
    @tags = @issue.tags
    @labels = @issue.labels
  end
  
  def tags
    @issues = Issue.tagged_with(params[:tag].to_s).paginate :page => params[:page], :per_page => 50
    @tags = Issue.tag_counts_on(:tags).order('name')
  end

  def labels
    @issues = Issue.tagged_with(params[:label].to_s, :on => :labels).paginate :page => params[:page], :per_page => 50
    @labels = Issue.tag_counts_on(:labels)
  end
  
  def new
    @issue = Issue.new
    @themes = Theme.all
  end
 
  def new_for_theme
    @theme = Theme.find params[:id]
    @issue = Issue.new
    @issue.themes << @theme
    @themes = Theme.all  end
 
  def create
    do_create @issue, :new
  end
  
  def create_for_theme
    @theme = Theme.find params[:id]
    do_create @theme, :new_for_theme
  end
  
  def edit
    @users = User.all
    @themes = Theme.all
  end

  def update
    if @issue.update_attributes(params[:issue])
      flash[:notice] = t('issues.flash.updated')
      redirect_to @issue
    else
      @users = User.all
      @themes = Theme.all
      render :action => :edit
    end
  end
  
  def destroy
    @issue.destroy
    flash[:notice] = t('issues.flash.destroyed')
    redirect_to :action => :index
  end
  
  def vote
    unless @vote
      @vote = Vote.new
      @vote.user = current_user
      @vote.issue = @issue
      if @vote.save
        #count_votes
        render 'votes'
        return
      end
    end
    render :nothing => true
  end
  
  def unvote
    if @vote
      @vote.destroy
      @vote = nil
      #count_votes
      render 'votes'
      return
    end
    render :nothing => true
  end

  def search
  end
  
  def searched
    query = "%#{params[:search]}%".downcase
    @issues = Issue.where("LOWER(title) LIKE ? OR LOWER(body) LIKE ?", query,query).lastest.includes(:user).paginate :page => params[:page], :per_page => 30
    render :search
  end
  
  private
  
  def do_create redirect_to, rerender_to
    params[:issue].delete(:label_list) unless can? :manage, Issue
    @issue = Issue.new(params[:issue])
    @issue.user = current_user
    if @issue.save
      current_user.follow @issue
      Publisher.publish @issue
      flash[:notice] = t('issues.flash.created')
      redirect_to redirect_to
    else
      @themes = Theme.all
      render rerender_to
    end
  end
  
  def find_issue
    @issue = Issue.find params[:id]
  end

  def find_vote
    @vote = Vote.first :conditions => { :user_id => current_user.id, :issue_id => @issue.id } if current_user
  end

  def count_votes
    @votes = @issue.votes.count
  end
  
  def load_sidebar
    @themes = Theme.all
    @most_commented = Issue.most_commented.includes(:user).limit(7)
    #@most_voted = Issue.most_voted.includes(:user).limit(7)
  end
  
  def find_popular_tags
    @popular_tags = Issue.tag_counts_on(:tags).order('count desc').limit(20)
  end
  
    
  
end
