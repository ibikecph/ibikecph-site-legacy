class IssuesController < ApplicationController
       
  skip_before_filter :require_login, :only => [:index,:show,:tag]
  load_and_authorize_resource
  skip_authorize_resource :only => :tag
  before_filter :find_vote, :only => [:show,:vote,:unvote]
  before_filter :load_sidebar, :only => [:index,:list,:create,:ideas,:tag]

  def index
    if params[:label]
      @issues = Issue.tagged_with(params[:label].to_s, :on => :labels).lastest.includes(:user).paginate :page => params[:page], :per_page => 10
    else
      @issues = Issue.lastest.includes(:user).paginate :page => params[:page], :per_page => 10
    end
  end
  
  def show
    count_votes
    @comments = @issue.comments
  end
  
  def tag
    @issues = Issue.tagged_with(params[:tag].to_s).paginate :page => params[:page], :per_page => 10
  end
  
  def new
    @issue = Issue.new
  end
 
  def create
    collect_labels
    @issue = Issue.new(params[:issue])
    @issue.user = current_user
    if @issue.save
      current_user.follow @issue
      Publisher.publish @issue
      flash[:notice] = 'Issue submitted.'
      redirect_to @issue
    else
      render :new
    end
  end

  def edit
    @users = User.all
  end

  def update
    collect_labels
    if @issue.update_attributes(params[:issue])
      flash[:notice] = "Successfully updated issue."
      redirect_to @issue
    else
      @users = User.all
      render :action => :edit
    end
  end
  
  def destroy
    @issue.destroy
    flash[:notice] = "Successfully destroyed issue."
    redirect_to :action => :index
  end
  
  def vote
    unless @vote
      @vote = Vote.new
      @vote.user = current_user
      @vote.issue = @issue
      if @vote.save
        count_votes
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
      count_votes
      render 'votes'
      return
    end
    render :nothing => true
  end

  
  private
  
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
    @most_commented = Issue.most_commented.includes(:user).limit(7)
    @most_voted = Issue.most_voted.includes(:user).limit(7)
    @issue = Issue.new
    @tags = Issue.tag_counts_on(:tags)
  end
  
  def collect_labels
    params[:issue][:label_list] = params[:labels].keys.join(' ') if params[:labels].is_a? Hash
  end
  
end
