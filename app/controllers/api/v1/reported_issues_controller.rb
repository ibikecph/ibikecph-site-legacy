class Api::V1::ReportedIssuesController < Api::V1::BaseController

  #skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  load_and_authorize_resource :user
  load_and_authorize_resource :reported_issue

  def index
    @reported_issues = ReportedIssue.where(is_open: true)
  end

  def create
    check_issue_encoding!

    @reported_issue = current_user.reported_issues.new issue_params

    if @reported_issue.save
      render status: 201,
             json: {
               success: true,
               info: t('reported_issues.flash.created'),
               data: { id: @reported_issue.id }
             }
    else
      render status: 422,
             json: {
               success: false,
               info: @reported_issue.errors.full_messages.first,
               errors: @reported_issue.errors.full_messages
             }
    end

  end

  def show
    @reported_issue = current_user.reported_issues.find_by(id: params[:id])

    unless @reported_issue
      render status: 404,
             json: {
               success: false,
               info: t('reported_issues.flash.issue_not_found'),
               errors: t('reported_issues.flash.issue_not_found')
             }
    end
  end

  def update
    @reported_issue = current_user.reported_issues.find_by(id: params[:id])

    unless @reported_issue
      render status: 404,
             json: {
               success: false,
               info: t('reported_issues.flash.issue_not_found'),
               errors: t('reported_issues.flash.issue_not_found')
             }
    else
      check_issue_encoding!

      # can? :update, ReportedIssue

      if @reported_issue.update_attributes issue_params
        render status: 200,
               json: {
                 success: true,
                 info: t('reported_issues.flash.updated'),
                 data: { id: @reported_issue.id }
               }
      else
        render status: 400,
               json: {
                 success: false,
                 info: @reported_issue.errors.full_messages.first,
                 errors: @reported_issue.errors.full_messages
               }
      end
    end
  end

  def destroy
    @reported_issue = current_user.reported_issues.find_by(id: params[:id])

    unless @reported_issue
      render status: 404,
             json: {
               success: false,
               info: t('reported_issues.flash.issue_not_found'),
               errors: t('reported_issues.flash.issue_not_found')
             }
    else
      @reported_issue.destroy

      render status: 200,
             json: {
               success: true,
               info: t('reported_issues.flash.deleted'),
               data: {}
             }
    end
  end

  private

  def issue_params
    params.require(:issue).permit(
      :route_segment,
      :comment,
      :error_type,
      :is_open
    )
  end

  # def check_auth_token
  #   if params[:auth_token] && !params[:auth_token].nil?
  #     :authenticate_user!
  #   end
  # end

  def check_issue_encoding!
    if params[:issue] &&
       params[:issue][:comment] &&
       !params[:issue][:comment].force_encoding('UTF-8').valid_encoding?

      params[:issue][:comment] = params[:issue][:comment]
                                 .force_encoding('ISO-8859-1')
                                 .encode('UTF-8')
    end
    if params[:issue] &&
       params[:issue][:route_segment] &&
       !params[:issue][:route_segment].force_encoding('UTF-8').valid_encoding?

      params[:issue][:route_segment] = params[:issue][:route_segment]
                                       .force_encoding('ISO-8859-1')
                                       .encode('UTF-8')
    end
    if params[:issue] &&
       params[:issue][:error_type] &&
       !params[:issue][:error_type].force_encoding('UTF-8').valid_encoding?

      params[:issue][:error_type] = params[:issue][:error_type]
                                    .force_encoding('ISO-8859-1')
                                    .encode('UTF-8')
    end
  end

end
