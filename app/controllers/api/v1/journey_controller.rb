class Api::V1::JourneyController < Api::V1::BaseController
  skip_before_filter :check_auth_token!

  def show
    @journey = TravelPlanner.get_journey(params[:loc])
    render json: @journey
  end
end