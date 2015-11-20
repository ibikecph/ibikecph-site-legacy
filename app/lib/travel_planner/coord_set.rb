class TravelPlanner::CoordSet
  def initialize(coord_data)
    @coords = coord_data
  end

  def coords
    @coords
  end

  def origin_coords
    [coords[0],coords[1]]
  end

  def dest_coords
    [coords[2],coords[3]]
  end

  def as_via_points
    [[coords[0],coords[1]], [coords[2],coords[3]]]
  end

  def for_travel
    travel_coords = coords.flatten.map { |x| (x.to_f * (10**6)).to_i }
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