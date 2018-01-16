class ReportedIssuesController < ApplicationController

  def index
    case params[:filter]
    when 'open'
      @reported_issues = ReportedIssue.open_issues
    when 'closed'
      @reported_issues = ReportedIssue.closed_issues
    else
      @reported_issues = ReportedIssue.order(created_at: :asc)
    end
  end

  def new
    @reported_issue = ReportedIssue.new
  end

  def create
    @reported_issue = ReportedIssue.new reported_issue_params
    @reported_issue.user_id = current_user.id if current_user
    if @reported_issue.save
      flash[:notice] = t('reported_issues.flash.created')
      redirect_to @reported_issue
    else
      render :new
    end

  end

  def show
    @reported_issue = ReportedIssue.find_by_id(params[:id])

    regex = /(55[\.,]\d+).+(12[\.,]\d+).+(55[\.,]\d+).+(12[\.,]\d+)/m
    m =  @reported_issue.comment.match(regex)
    if m
      @from = [m[1].sub(',', '.').to_f,m[2].sub(',', '.').to_f]
      @to   = [m[3].sub(',', '.').to_f,m[4].sub(',', '.').to_f]
      @map_link_title = "#{@from.join(',')} to #{@to.join('.')}"
      @map_url = "/#!/#{@from.join(',')}/#{@to.join(',')}"
    end
  end

  def edit
    @reported_issue = ReportedIssue.find_by_id(params[:id])
  end

  def update
    @reported_issue = ReportedIssue.find_by_id(params[:id])

    if @reported_issue.update_attributes reported_issue_params
      flash[:notice] = t('reported_issues.flash.updated')
      redirect_to @reported_issue
    else
      render action: :edit
    end
  end

  def destroy
    @reported_issue = ReportedIssue.find_by_id(params[:id])
    @reported_issue.destroy

    flash[:notice] = t('reported_issues.flash.destroyed')
    redirect_to action: :index
  end

  private

  def reported_issue_params
    params.require(:reported_issue).permit(
      :route_segment,
      :comment,
      :error_type,
      :is_open
    )
  end

end
