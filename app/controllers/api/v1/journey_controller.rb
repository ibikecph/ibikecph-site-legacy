class Api::V1::JourneyController < Api::V1::BaseController
  def show
    begin
      @journey = TravelPlanner.get_journey(params[:journey])
      render json: @journey
    rescue TravelPlanner::FormattingError => e
      render json: { error: e.message }
    end
  end
end