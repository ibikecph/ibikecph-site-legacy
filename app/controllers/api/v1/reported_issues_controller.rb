class Api::V1::ReportedIssuesController < ApplicationController 
  
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  before_filter :check_auth_token
  def index
    @reported_issues=ReportedIssue.find(:all, :conditions=>{:is_open=>true})
  end
  
  def create    
        @reported_issue = ReportedIssue.new params[:issue]
        @reported_issue.user_id=current_user.id if current_user
        if @reported_issue.save          
           render :status => 201,
           :json => { :success => true,
                      :info => "Issue created successfully!",
                      :data => { :id => @reported_issue.id } }
        else
           render :status => 422,
           :json => { :success => false,
                      :info => "Process Failed", 
                      :errors => @reported_issue.errors.messages}
        end
    
  end
  
  def show
     @reported_issue=ReportedIssue.find_by_id(params[:id])
     rescue ActiveRecord::RecordNotFound
           render :status => 404,
           :json => { :success => false,
                      :info => "Process Failed", 
                      :errors => "Issue doesn't exist!"}      
  end
  
  def update
    @reported_issue=ReportedIssue.find_by_id(params[:id])
    if @reported_issue.update_attributes(params[:issue])
           render :status => 200,
           :json => { :success => true,
                      :info => "Issue updated successfully!",
                      :data => { :id => @reported_issue.id } }
    else
           render :status => 400,
           :json => { :success => false,
                      :info => "Process Failed", 
                      :errors => @reported_issue.errors.messages}   
    end
  end
  
  def destroy
    @reported_issue=ReportedIssue.find_by_id(params[:id])
    @reported_issue.destroy
     render :status => 200,
     :json => { :success => true,
                :info => "Issue deleted successfully!",
                :data => {} }
  end
  
  private
  
  def check_auth_token
    if params[:auth_token] && !params[:auth_token].nil?
      :authenticate_user!
    end
  end
  
end