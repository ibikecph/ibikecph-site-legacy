class Api::V1::ReportedIssuesController < Api::V1::BaseController
  
 
  before_filter :check_auth_token
  
  def index
    @reported_issues=ReportedIssue.find(:all, :conditions=>{:is_open=>true})
  end
  
  def create
        params[:issue][:comment]=params[:issue][:comment].force_encoding('ISO-8859-15').encode('UTF-8') if params[:issue] && params[:issue][:comment]
        params[:issue][:route_segment]=params[:issue][:route_segment].force_encoding('ISO-8859-15').encode('UTF-8') if params[:issue] && params[:issue][:route_segment]
        params[:issue][:error_type]=params[:issue][:error_type].force_encoding('ISO-8859-15').encode('UTF-8') if params[:issue] && params[:issue][:error_type]    
        @reported_issue = ReportedIssue.new params[:issue]
        @reported_issue.user_id=current_user.id if current_user
        if @reported_issue.save          
           render :status => 201,
           :json => { :success => true,
                      :info => t('reported_issues.flash.created'),
                      :data => { :id => @reported_issue.id } }
        else
           render :status => 422,
           :json => { :success => false,
                      :info => @reported_issue.errors.full_messages.first, 
                      :errors => @reported_issue.errors.full_messages}
        end
    
  end
  
  def show
     @reported_issue=ReportedIssue.find_by_id(params[:id])
     if !@reported_issue
           render :status => 404,
           :json => { :success => false,
                      :info => t('reported_issues.flash.issue_not_found'), 
                      :errors => t('reported_issues.flash.issue_not_found')}   
     end   
  end
  
  def update
    @reported_issue=ReportedIssue.find_by_id(params[:id])
    if @reported_issue.update_attributes(params[:issue])
           render :status => 200,
           :json => { :success => true,
                      :info => t('reported_issues.flash.updated'),
                      :data => { :id => @reported_issue.id } }
    else
           render :status => 400,
           :json => { :success => false,
                      :info => @reported_issue.errors.full_messages.first, 
                      :errors => @reported_issue.errors.full_messages}  
    end
  end
  
  def destroy
    @reported_issue=ReportedIssue.find_by_id(params[:id])
    if @reported_issue
    @reported_issue.destroy
     render :status => 200,
     :json => { :success => true,
                :info => t('reported_issues.flash.deleted'),
                :data => {} }
    else
      render :status => 404,
      :json => { :success => false,
                :info => t('reported_issues.flash.issue_not_found'), 
                :errors => t('reported_issues.flash.issue_not_found')}                 
    end              
  end
  
  private
  
  def check_auth_token
    if params[:auth_token] && !params[:auth_token].nil?
      :authenticate_user!
    end
  end
  
end