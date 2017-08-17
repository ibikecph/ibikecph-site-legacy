class Api::V1::RoutesController < Api::V1::BaseController
  before_action :scrub_invalid_byte_sequences
  before_action :manage_duplicate_routes, only: :create

  load_and_authorize_resource :user
  load_and_authorize_resource :route

  def index
    @routes = current_user.routes.recent_routes
  end

  def create
    @route = current_user.routes.new route_params
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
    @route = current_user.routes.find_by id: params[:id]

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
    @route = current_user.routes.find_by id: params[:id]

    unless @route
      render status: 404,
             json: {
               success: false,
               info: t('routes.flash.route_not_found'),
               errors: t('routes.flash.route_not_found')
             }
    else
      if @route.update_attributes(route_params)
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
  end

  def destroy
      @route = current_user.routes.find_by id: params[:id]

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

  def route_params
    # preserve backwards compatability
    if !params[:route][:from_lattitude].nil? && params[:route][:from_latitude].nil?
      params[:route][:from_latitude] = params[:route][:from_lattitude]
    end
    if !params[:route][:to_lattitude].nil? && params[:route][:to_latitude].nil?
      params[:route][:to_latitude] = params[:route][:to_lattitude]
    end

    params.require(:route).permit(
      :from_name,
      :from_latitude,
      :from_longitude,
      :to_name,
      :to_latitude,
      :to_longitude,
      :route_geometry,
      :route_instructions,
      :route_summary,
      :route_name,
      :start_date,
      :end_date,
      :route_visited_locations,
      :is_finished
    )
  end

  def manage_duplicate_routes
    @croute = current_user.routes.find_by(
      from_name: params[:route][:from_name],
      to_name: params[:route][:to_name]
    )

    @croute.destroy if @croute
  end

  def scrub_invalid_byte_sequences
    if params[:route]
      params[:route][:from_name].scrub! if params[:route][:from_name]
      params[:route][:to_name].scrub! if params[:route][:to_name]
    end
  end

end
