class TravelPlanner::Journey
  include HTTParty

  base_uri ENV['REJSEPLANEN_API_URL']

  def initialize(options)
    @coords = TravelPlanner::CoordSet.new options[:coords]
    #@origin_coord_x = options[:originCoordX]
    #@origin_coord_y = options[:originCoordY]
    #@dest_coord_x = options[:destCoordX]
    #@dest_coord_y = options[:destCoordY]

    @journey_data = fetch_journey_data(options)
  end

  def trips
    format_trips @journey_data
  end

  private
  def fetch_journey_data(options)
    Rails.cache.fetch('journeysan', expires_in: 2.minutes) do
      coords = TravelPlanner::CoordSet.new options[:coords]
      options.merge!(coords.as_travel).delete(:coords)
      self.class.get('/trips/', query: options,  headers: {'Content-Type' => 'application/json'} )['TripList']['Trip']
    end
  end

  def format_trips(trips)
    trips.map {|trip| (trip['Leg'].map {|leg| (leg['type'] == 'BIKE') ? format_bike : format_train(leg)})}
  end

  # We're formatting the response so it mirrors our OSRM-routers bike response.
  def format_train(leg_data)
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

        via_points: leg.coords,

        route_instructions: build_route_instructions(leg),
        route_geometry: Polylines::Encoder.encode_points(leg.coords)
    }
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

  def format_bike
    options = {
        loc: @coords.as_ibike,
        z: 18,
        alt: false,
        instructions:true
    }

    # This HTTParty method enables us to send loc as an array.
    self.class.disable_rails_query_string_format
    self.class.get('http://routes.ibikecph.dk/v1.1/fast/viaroute', query: options)
  end
end