class Api::V1::JourneyController < Api::V1::BaseController
  #todo improve and translate error messages
  skip_before_filter :check_auth_token!

  #rescue_from StandardError, with: :error_message

  def show
    @journey = TravelPlanner.get_journey(params[:loc])
    render json: @journey
  end

  def error_message(e)
    render json: {error: e.message}, status: 422
  end
end