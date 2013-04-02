class Api::V1::ReportedIssuesController < ApplicationController 
  
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  
  def index
    @reported_issues=ReportedIssue.find(:all, :conditions=>{:is_open=>true})

  end
  
  def create
    
        @reported_issue = ReportedIssue.new params[:issue]
        if @reported_issue.save
          
            render :status => 201,
           :json => { :success => true,
                      :info => "Issue created. Successfully!",
                      :data => { :id => @reported_issue.id } }
        else
           render :status => 422,
           :json => { :success => false,
                      :errors => @reported_issue.errors}

        end
    
  end
  
  def show
     @reported_issue=ReportedIssue.find_by_id(params[:id])
     render :status => 200,
           :json => { :success => true,
                      :info => "LIst of Reported Issues",
                      :data => { :items => @reported_issue } }
  end
  
end