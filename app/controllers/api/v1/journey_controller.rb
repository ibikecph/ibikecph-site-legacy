class Api::V1::JourneyController < Api::V1::BaseController
  skip_before_filter :check_auth_token!

  rescue_from TravelPlanner::Error, with: :error_message

  def show
    render json: TravelPlanner.get_journey(params[:loc])
  end

  def error_message(e)
    render json: {error: e.message}, status: 422
  end
end