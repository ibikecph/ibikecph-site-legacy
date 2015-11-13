module TravelPlanner
  require 'travel_planner/journey'
  require 'travel_planner/leg'

  def self.get_journey(options={})
    journey = Journey.new(options)
    journey.trips
  end

  class CoordSet
    def initialize(coords)
      @coords = coords
    end

    def as_travel
      travel_coords = @coords.map { |x| x.tr('.','') }
      {
          originCoordX: travel_coords[0],
          originCoordY: travel_coords[1],
          destCoordX:   travel_coords[2],
          destCoordY:   travel_coords[3]
      }
    end

    def as_ibike
      [ @coords[0]+','+@coords[1],@coords[2]+','+@coords[3] ]
    end
  end
end