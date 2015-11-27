module TravelPlanner
  require 'travel_planner/errors'

  include HTTParty
  default_timeout 8
  disable_rails_query_string_format # for ibike routing server
  base_uri ENV['REJSEPLANEN_API_URL']

  def self.get_journey(loc)
    Journey.new(options(loc)).trips
  end

  def self.options(loc)
    { loc: loc.map {|coord| coord.split(',')}.flatten,
      originCoordName: '\0',
      destCoordName: '\0',
      useBicycle: 1,
      maxCyclingDistanceDep: 5000,
      maxCyclingDistanceDest: 5000,
      format: 'json' }
  end
end