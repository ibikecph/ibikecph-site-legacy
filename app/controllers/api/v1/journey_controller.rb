class Api::V1::JourneyController < Api::V1::BaseController
  require "#{Rails.root}/lib/travel_planner.rb"

  def show
    TravelPlanner.get_journey(params[:options])
  end
end