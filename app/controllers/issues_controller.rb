class IssuesController < ApplicationController
       
  before_filter :require_login, :only => [:new,:create]
  before_filter :find_issue, :except => [:old_show,:list,:index,:new,:create]
  #authorize_resource :except => [:list,:new,:create]
  before_filter :find_vote, :only => [:show,:vote,:unvote]
  before_filter :prep, :only => [:index,:list,:create]

  def index
    @issues = Issue.lastest.includes(:user).paginate :page => params[:page], :per_page => 10
  end

  def show
    count_votes
    @comments = @issue.comments
  end
  
  def new
    @issue = Issue.new
  end
 
  def create
    @issue = Issue.new(params[:issue])
    @issue.user = current_user
 
    @issues = Issue.lastest.includes(:user,:visualizations).paginate :page => params[:page], :per_page => 20
    
    if @issue.save
      
      begin
        Publisher.publish_issue @issue
      rescue Exception => e
        logger.error "*** Error: Could not publish issue #{@issue.title}: #{e}"
      end
      
      begin
        Notifier.issue @issue
      rescue Exception => e
        logger.error "*** Error: Could not send notificatons for issue #{@issue.title}: #{e}"
      end
      
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
  
  def prep
    @most_commented = Issue.most_commented.includes(:user).limit(7)
    @most_voted = Issue.most_voted.includes(:user).limit(7)
    @issue = Issue.new
  end

end
