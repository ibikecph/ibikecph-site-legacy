class TravelPlanner::Journey
  include HTTParty

  base_uri ENV['REJSEPLANEN_API_URL']

  def initialize(options)
    @coords = TravelPlanner::CoordSet.new options[:loc]
    @journey_data = fetch_journey_data options.merge(@coords.for_travel)

    # This HTTParty method enables us to send loc as an array.
    self.class.disable_rails_query_string_format
  end

  def trips
    format_journeys @journey_data
  end

  private
  def fetch_journey_data(query)
    response = self.class.get('/trips/', query: query)
    response ? response['TripList']['Trip'] : raise(TravelPlanner::ConnectionError)
  end

  def format_journeys(journey_data)
    journey_data.map {|journey| format_legs(journey) }
  end

  def format_legs(journey_data)
    @total_time = 0
    @total_distance = 0
    @total_bike_distance = 0

    journey = journey_data['Leg'].map { |leg| format(leg) }

    {journey_summary:{
        end_point: 'filler_end_point',
        start_point: 'filler_start_point',
        total_time: @total_time,
        total_distance: @total_distance,
        total_bike_distance: @total_bike_distance
      },
      journey:journey
    }
  end

  def format(leg)
    points = {origin: leg['Origin'], destination: leg['Destination']}

    coords = TravelPlanner::CoordSet.new points.map { |point_pos,point| extract_coords(point_pos,point)}.flatten

    if leg['type']=='BIKE'
      format_bike(leg,coords)
    else
      format_train(leg,coords)
    end
  end

  # We're formatting the response so it mirrors our OSRM-routers bike response.
  def format_train(leg_data,coords)
    leg = TravelPlanner::Leg.new leg_data
    @total_time += leg.total_time
    @total_distance += leg.distance(coords.for_polyline)
    {
        route_name: [
            leg.origin['name'],
            leg.destination['name']
        ],

        route_summary: {
            end_point:      leg.destination['name'],
            start_point:    leg.origin['name'],
            time:           leg.total_time,
            distance:       leg.distance(coords.for_polyline),
            type:           leg.type,
            name:           leg.name,
            departure_time: leg.departure_time,
            arrival_time:   leg.arrival_time
        },

        via_points: coords.as_via_points,

        route_instructions: build_route_instructions(leg),
        route_geometry: Polylines::Encoder.encode_points(coords.for_polyline)
    }
  end

  def format_bike(leg_data,coords)
    leg = TravelPlanner::Leg.new leg_data

    options = {
        loc: coords.for_ibike,
        z: 18,
        alt: false,
        instructions:true
    }

    response = self.class.get('http://routes.ibikecph.dk/v1.1/fast/viaroute', query: options)
    raise TravelPlanner::ConnectionError unless response['route_summary']

    response['route_summary'].merge!({
        type: leg.type,
        departure_time: leg.departure_time,
        arrival_time: leg.arrival_time
    })
    @total_time += response['route_summary']['total_time']
    @total_distance += response['route_summary']['total_distance']
    @total_bike_distance += response['route_summary']['total_distance']

    response
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

  def extract_coords(point_pos,point)
    if point['type'] == 'ADR'
      case point_pos
        when :origin
          @coords.origin_coords
        when :destination
          @coords.dest_coords
        else
          raise TravelPlanner::Error
      end
    else
      Rails.cache.fetch(point['name'], expires_in: 3.days) do
        query = {'input': point['name']}

        location = self.class.get('/location/', query: query)['LocationList']['StopLocation']
        raise TravelPlanner::Error unless location
        station = location.detect{|s| s['name'] == point['name']}

        %w(y x).map{|coord| (station[coord].to_f / 10**6).to_s}
      end
    end
  end
end
