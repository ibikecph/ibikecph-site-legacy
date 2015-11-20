class TravelPlanner::Journey
  include HTTParty

  base_uri ENV['REJSEPLANEN_API_URL']

  def initialize(options)
    @coords = TravelPlanner::CoordSet.new options[:loc]
    @journey_data = fetch_journey_data options.merge(@coords.for_travel)
  end

  def trips
    format_journeys @journey_data
  end

  def fetch_journey_data(query)
    response = self.class.get('/trips/', query: query)
    response ? response['TripList']['Trip'] : raise('Rejseplanen could could not be reached.')
  end

  private
  def format_journeys(journey_data)
    { meta: {
        route_summary: {
            end_point: 'filler_end_point',
            start_point: 'filler_start_point',
            total_time: '5555',
            total_distance: '5555'
        }
    },
      journeys: journey_data.map {|journey| (journey['Leg'].map {|leg| format(leg) }) }
    }
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
            total_time:  leg.total_time,
            type:        leg.type
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
    response = self.class.get('http://routes.ibikecph.dk/v1.1/fast/viaroute', query: options)
    raise 'ibike routing server could not be reached.' unless response['route_summary']
    response['route_summary']['type']='BIKE'
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
    case point['type']
      when 'ST'
        Rails.cache.fetch(point['name'], expires_in: 3.days) do
          query = {'input': point['name']}

          location = self.class.get('/location/', query: query)['LocationList']['StopLocation']
          raise 'An unknown error occurred' unless location
          station = location.detect{|s| s['name'] == point['name']}

          %w(y x).map{|coord| (station[coord].to_f / 10**6).to_s}
        end
      when 'ADR'
        case point_pos
          when :origin
            @coords.origin_coords
          when :destination
            @coords.dest_coords
          else
            raise 'Correct coords not supplied.'
        end
      else
        raise 'We cannot fetch.'
    end
  end
end
