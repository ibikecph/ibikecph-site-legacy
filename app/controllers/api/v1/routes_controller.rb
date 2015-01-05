class Api::V1::RoutesController < Api::V1::BaseController

  skip_before_filter :verify_authenticity_token, if: Proc.new { |c| c.request.format == 'application/json' }
  before_filter :check_auth, if: Proc.new { |c| c.request.format == 'application/json' }
  before_filter :manage_duplicate_routes, only: :create
  load_and_authorize_resource :user

  def index
    @routes = current_user.routes.recent_routes
  end

  def create
    if params[:route] &&
       params[:route][:from_name] &&
       !params[:route][:from_name].force_encoding('UTF-8').valid_encoding?

      params[:route][:from_name] = params[:route][:from_name]
                                   .force_encoding('ISO-8859-1')
                                   .encode('UTF-8')
    end
    if params[:route] &&
       params[:route][:to_name] &&
       !params[:route][:to_name].force_encoding('UTF-8').valid_encoding?

      params[:route][:to_name] = params[:route][:to_name]
                                 .force_encoding('ISO-8859-1')
                                 .encode('UTF-8')
    end

    @route = current_user.routes.new params[:route]
    if @route.save
      render status: 201,
             json: {
               success: true,
               info: t('routes.flash.created'),
               data: { id: @route.id }
             }
    else
      render status: 422,
             json: {
               success: false,
               info: @route.errors.full_messages.first,
               errors: @route.errors.full_messages
             }
    end
  end

  def show
    @route = current_user.routes.find_by_id(params[:id])

    unless @route
      render status: 404,
             json: {
               success: false,
               info: t('routes.flash.route_not_found'),
               errors: t('routes.flash.route_not_found')
             }
    end
  end

  def update
    @route = current_user.routes.find_by_id(params[:id])

    if params[:route] &&
       params[:route][:from_name] &&
       !params[:route][:from_name].force_encoding('UTF-8').valid_encoding?

      params[:route][:from_name] = params[:route][:from_name]
                                   .force_encoding('ISO-8859-1')
                                   .encode('UTF-8')
    end
    if params[:route] &&
       params[:route][:to_name] &&
       !params[:route][:to_name].force_encoding('UTF-8').valid_encoding?

      params[:route][:to_name] = params[:route][:to_name]
                                 .force_encoding('ISO-8859-1')
                                 .encode('UTF-8')
    end

    if @route.update_attributes(params[:route])
      render status: 200,
             json: {
               success: true,
               info: t('routes.flash.updated'),
               data: { id: @route.id }
             }
    else
      render status: 400,
             json: {
               success: false,
               info: @route.errors.full_messages.first,
               errors: @route.errors.full_messages
             }
    end
  end

  def destroy
    @route = current_user.routes.find_by_id(params[:id])

    if @route
      @route.destroy
      render status: 200,
             json: {
               success: true,
               info: t('routes.flash.deleted'),
               data: {}
             }
    else
      render status: 404,
             json: {
               success: false,
               info: t('routes.flash.route_not_found'),
               errors: t('routes.flash.route_not_found')
             }
    end
  end

  private

  def manage_duplicate_routes
    @croute = current_user.routes
              .find_by_from_name_and_to_name(params[:route][:from_name], params[:route][:to_name])

    @croute.destroy if @croute
  end

end
