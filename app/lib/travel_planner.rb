module TravelPlanner
  require 'travel_planner/journey'
  require 'travel_planner/leg'

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

  class CoordSet
    attr_accessor :origin_coords, :dest_coords

    def initialize(coord_data)
      self.origin_coords = [coord_data[0],coord_data[1]]
      self.dest_coords   = [coord_data[2],coord_data[3]]
    end

    def coords
      self.origin_coords + self.dest_coords
    end

    def as_via_points
      [[ coords[0],coords[1]], [coords[2],coords[3]]]
    end

    def for_travel
      travel_coords = coords.flatten.map { |x| x.tr('.','') }
      {
          originCoordX: travel_coords[1],
          originCoordY: travel_coords[0],
          destCoordX:   travel_coords[3],
          destCoordY:   travel_coords[2]
      }
    end

    def for_ibike
      [ coords[0]+','+coords[1], coords[2]+','+coords[3] ]
    end

    def for_polyline
      poly_coords = coords.map {|coord| coord.to_f}
      [[poly_coords[0],poly_coords[1]], [poly_coords[2],poly_coords[3]]]
    end
  end
end