class TravelPlanner::Leg
  def initialize(leg_data,coord_data)
    @data = leg_data
    @coords = TravelPlanner::CoordSet.new coord_data
  end

  def coords
    @coords
  end

  def origin
    @origin ||= @data['Origin']
  end

  def destination
    @destination ||= @data['Destination']
  end

  def name
    @data['name']
  end

  def type
    @data['type']
  end

  def departure_time
    @departure_time ||= parse_time(origin['date'],origin['time'])
  end

  def arrival_time
    @arrival_time ||= parse_time(destination['date'],destination['time'])
  end

  def total_time
    @total_time ||= (arrival_time-departure_time)
  end

  def distance
    @distance ||= calculate_distance @coords.for_polyline
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

  def route_geometry
    ref = HTTParty.get(@data['JourneyDetailRef']['ref'])['JourneyDetail']['Stop']
    raise TravelPlanner::ConnectionError unless ref

    coords = (origin['routeIdx']..destination['routeIdx']).map do |id|
      station = ref.detect{ |s| s['routeIdx'] == id }
      Rails.cache.fetch(station['name'], expires_in: 3.days) do
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
  def route_instructions
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
        1,
        total_time,
        distance.to_s + 'm',
        'N',
        '4'
    ]

    [start_instructions,end_instructions]
  end

  private
  def parse_time(date,time)
    format = '%d.%m.%y%H:%M'
    offset = ActiveSupport::TimeZone['Copenhagen'].utc_offset

    Time.strptime(date + time, format).to_i - offset
  end
end