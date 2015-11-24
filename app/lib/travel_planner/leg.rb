class TravelPlanner::Leg
  def initialize(data)
    @data = data
  end

  def origin
    @origin ||= @data['Origin']
  end

  def destination
    @destination ||= @data['Destination']
  end

  def name
    @name ||= @data['name']
  end

  def type
    @type ||= @data['type']
  end

  def departure_time
    @departure_time ||= parse_time(origin)
  end

  def arrival_time
    @arrival_time ||= parse_time(destination)
  end

  def total_time
    @total_time ||= (arrival_time-departure_time)
  end

  # taken from http://stackoverflow.com/questions/12966638/how-to-calculate-the-distance-between-two-gps-coordinates-without-using-google-m
  def distance loc
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

  private
  def parse_time(point)
    format = '%d.%m.%y%H:%M%z'
    offset = '+0' + (ActiveSupport::TimeZone['Copenhagen'].utc_offset / 3600).to_s

    Time.strptime(point['date'] + point['time'] + offset,format).to_i
  end
end