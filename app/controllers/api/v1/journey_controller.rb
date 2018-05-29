class Api::V1::JourneyController < Api::V1::BaseController
  skip_before_action :check_auth_token!
  skip_before_action :verify_authenticity_token

  rescue_from TravelPlanner::Error, with: :travel_planner_message
  rescue_from StandardError, with: :standard_message

  def create
    remove_outdated_journeys
    journey = Journey.new
    journey.save!
    journey.delay.fetch params[:loc]      # use delayed_job's delay() to defer to a background job
    render json: {token:journey.token}
  end

  def show
    journey = Journey.find_by_token params[:token]
    if journey
      if journey.ready
        if (Time.now - journey.updated_at) < 1.minutes
          render json: journey.content
        else
          render json: {error: 'outdated'}, status: 410     # 410: Gone
        end
      else
        render json: {error: 'not ready'}, status: 422     # 422: Unprocesable enitiry
      end
    else
      render json: {error: 'not found'}, status: 404        # 404 Not found
    end
  end

  def travel_planner_message(e)
    render json: {error: e.message}, status: 422
  end

  def standard_message(e)
    ExceptionNotifier.notify_exception(e, env: request.env)
    render json: {error: 'An unexpected error occurred.'}, status: 500
  end

  private

  def remove_outdated_journeys
    # destroy all journey models older than 10 minutes
    Journey.where("created_at < '#{10.minutes.ago}'").delete_all
  end

end
