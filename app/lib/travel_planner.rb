module TravelPlanner
  require 'travel_planner/journey'
  require 'travel_planner/leg'
  require 'travel_planner/coord_set'

  class FormattingError < StandardError; end

  def self.get_journey(options={})
    journey = Journey.new(options.merge(default_options))
    journey.trips
  end

  def self.default_options
    {originCoordName: '\0',
     destCoordName: '\0',
     useBicycle: 1,
     maxCyclingDistanceDep: 20000,
     maxCyclingDistanceDest: 20000,
     format: 'json'}
  end
end