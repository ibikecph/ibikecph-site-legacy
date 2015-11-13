module TravelPlanner
  require 'travel_planner/journey'
  require 'travel_planner/leg'

  def self.get_journey(options={})
    journey = Journey.new(options)
    journey.trips
  end
end