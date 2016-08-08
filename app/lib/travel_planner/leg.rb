class TravelPlanner::Leg
  attr_reader :data, :origin, :destination, :name, :type,
              :coords, :departure_time, :arrival_time, :total_time

  def initialize(leg_data, global_coords)
    @data        = leg_data
    @origin      = data['Origin']
    @destination = data['Destination']
    @name        = data['name']
    @type        = data['type']
    @coords      = extract_coords(global_coords)

    @departure_time = parse_time(origin)
    @arrival_time   = parse_time(destination)
    @total_time     = arrival_time - departure_time - 60
  end

  def distance
    calculate_distance coords.for_polyline
  end

  def route_instructions
    build_route_instructions
  end

  def route_geometry
    get_route_geometry
  end

  private
  def parse_time(station)
    # No timezone is supplied by Rejseplanen, thus we assume Copenhagen.
    offset_in_seconds = TZInfo::Timezone.get('Europe/Copenhagen').current_period.utc_total_offset
    offset_in_hours = (2*offset_in_seconds / 3600).ceil.to_s
    format = '%d.%m.%y%H:%M%z'

    Time.strptime(station['date'] + station['time'] + '+0' + offset_in_hours, format).to_i
  end

  def extract_coords(global_coords)
    stops = {origin: origin, destination: destination}

    coords = stops.map do |stop_end,stop|
      if stop['type'] == 'ADR'
        global_coords.send(stop_end)
      else
        Rails.cache.fetch(stop['name']) do
          location = TravelPlanner.get('/location/', query: {'input': stop['name']})['LocationList']['StopLocation']
          station  = location.detect{|s| s['name'] == stop['name']}

          %w(y x).map{ |coord| station[coord].to_f / 10**6 }
        end
      end
    end

    TravelPlanner::CoordSet.new coords.flatten
  end

  def get_route_geometry
    journey_details_ref = self.data['JourneyDetailRef']['ref']
    journey_details = TravelPlanner.get(journey_details_ref)
    stops = journey_details['JourneyDetail']['Stop']

    coords = (self.origin['routeIdx']..self.destination['routeIdx']).map do |id|
      station = stops.detect{ |s| s['routeIdx'] == id }

      Rails.cache.fetch(station['name']) do
        %w(y x).map{|coord| (station[coord].to_f / 10**6)}
      end
    end

    Polylines::Encoder.encode_points(coords)
  end

  # Route_instructions structure
  # 0 - ordinalDirection
  # 1 - name
  # 2 - prevLengthInMeters
  # 3 - waypointIndex
  # 4 - timeInSeconds
  # 5 - prevLengthInUnit
  # 6 - directionAbbreviation
  # 7 - azimuth
  # 8 - vehicle
  def build_route_instructions
    start_instructions = [
        '18',
        origin['name'],
        0,
        0,
        0,
        '0m',
        'N',
        '4'
    ]

    end_instructions = [
        '19',
        destination['name'],
        distance,
        1, # FIXME: This should be waypoints.size()-1 instead
        total_time,
        distance.to_s + 'm',
        'N',
        '4'
    ]

    [start_instructions,end_instructions]
  end

  # taken from http://stackoverflow.com/questions/12966638/how-to-calculate-the-distance-between-two-gps-coordinates-without-using-google-m
  def calculate_distance(loc)
    loc1 = loc[0]
    loc2 = loc[1]
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    (rm * c).to_i # Delta in meters
  end
end
