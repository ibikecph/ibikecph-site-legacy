class TravelPlanner::Journey
  include HTTParty

  base_uri ENV['REJSEPLANEN_API_URL']

  @headers = {'Content-Type' => 'application/json'}

  def initialize(options)
    @coords = TravelPlanner::CoordSet.new options[:coords]

    @journey_data = fetch_journey_data(options)
  end

  def trips
    format_trips @journey_data
  end

  private
  def fetch_journey_data(options)
    data = Rails.cache.fetch('journeys', expires_in: 10.minutes) do
      coords = TravelPlanner::CoordSet.new options[:coords]
      options.merge!(coords.for_travel).delete(:coords)
      self.class.get('/trips/', query: options,  headers: @headers )['TripList']['Trip']
    end

    data ? data : raise("Format doesn't work")
  end

  def format_trips(trips)
    trips.map {|trip| (trip['Leg'].map {|leg| format(leg) }) }
  end

  def format(leg)
    points = {origin: leg['Origin'], destination: leg['Destination']}

    coords = TravelPlanner::CoordSet.new points.map { |point_pos,point| extract_coords(point_pos,point)}.flatten

    if leg['type']=='BIKE'
      format_bike(coords)
    else
      format_train(leg,coords)
    end
  end

  # We're formatting the response so it mirrors our OSRM-routers bike response.
  def format_train(leg_data,coords)
    leg = TravelPlanner::Leg.new leg_data
    {
        route_name: [
            leg.origin['name'],
            leg.destination['name']
        ],

        route_summary: {
            end_point:   leg.destination['name'],
            start_point: leg.origin['name'],
            total_time:  leg.total_time
        },

        via_points: coords.as_via_points,

        route_instructions: build_route_instructions(leg),
        route_geometry: Polylines::Encoder.encode_points(coords.for_polyline)
    }
  end

  def format_bike(coords)
    options = {
        loc: coords.for_ibike,
        z: 18,
        alt: false,
        instructions:true
    }

    # This HTTParty method enables us to send loc as an array.
    self.class.disable_rails_query_string_format
    self.class.get('http://routes.ibikecph.dk/v1.1/fast/viaroute', query: options)
  end

  # Route_instructions structure
  # 0 - ordinalDirection
  # 1 - name
  # 2 - prevLengthInMeters
  # 3 - timeInSeconds
  # 4 - prevLengthInUnit
  # 5 - directionAbbreviation
  # 6 - azimuth
  # 7 - vehicle
  def build_route_instructions(leg)
    start_instructions = [
        '18',
        leg.origin['name'],
        0,
        0,
        '0m',
        'N',
        '4'
    ]

    end_instructions = [
        '19',
        leg.destination['name'],
        0,
        leg.total_time,
        leg.total_time.to_s + 'm',
        'N',
        '4'
    ]

    [start_instructions,end_instructions]
  end

  #TODO move somewhere else
  def extract_coords(point_pos,point)
    case point['type']
      when 'ST'
        Rails.cache.fetch(point['name'], expires_in: 10.seconds) do
          query = {'input': point['name']}
          location = self.class.get('/location/', query: query, headers: @headers)['LocationList']['StopLocation']
          station = location.detect{|s| s['name'] == point['name']}

          [station['y'].insert(2,'.'), station['x'].insert(2,'.')]
        end
      when 'ADR'
        case point_pos
          when :origin
            @coords.origin_coords
          when :destination
            @coords.dest_coords
          else
            raise StandardError
        end
      else
        raise StandardError
    end
  end
end