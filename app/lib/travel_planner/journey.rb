class TravelPlanner::Journey
  include HTTParty
  disable_rails_query_string_format # for ibike routing server
  base_uri ENV['REJSEPLANEN_API_URL']

  def initialize(options)
    @coords = TravelPlanner::CoordSet.new options[:loc]
    @journey_data = fetch_journey_data options.merge(@coords.for_travel)
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
    journey_data.first(3).map {|journey| format_legs(journey) }
  end

  def format_legs(journey_data)
    total_time = total_distance = total_bike_distance = 0

    journey = journey_data['Leg'].map do |leg|
      formatted_leg = format(leg)

      total_time          += formatted_leg['route_summary']['total_time']
      total_distance      += formatted_leg['route_summary']['total_distance']
      total_bike_distance += formatted_leg['route_summary']['total_distance'] if leg['type'] == 'BIKE'

      formatted_leg
    end

    {
      journey_summary:{
        total_time: total_time,
        total_distance: total_distance,
        total_bike_distance: total_bike_distance
      },
      journey:journey
    }
  end

  def format(leg_data)
    stops = {origin: leg_data['Origin'], destination: leg_data['Destination']}

    coords = stops.map { |stop_end,stop| extract_coords(stop_end, stop)}.flatten

    leg = TravelPlanner::Leg.new leg_data, coords

    if leg.type=='BIKE'
      format_bike(leg)
    else
      format_public(leg)
    end
  end

  # We're formatting the response so it mirrors our OSRM-routers bike response.
  def format_public(leg)
    {
        route_name: [
            leg.origin['name'],
            leg.destination['name']
        ],

        route_summary: {
            start_point:    leg.origin['name'],
            end_point:      leg.destination['name'],
            total_time:     leg.total_time,
            total_distance: leg.distance,
            type:           leg.type,
            name:           leg.name,
            departure_time: leg.departure_time,
            arrival_time:   leg.arrival_time
        },

        route_instructions: leg.route_instructions,
        route_geometry:     leg.route_geometry,

        via_points: leg.coords.as_via_points
    }.with_indifferent_access
  end

  def format_bike(leg)
    options = {
        loc: leg.coords.for_ibike,
        z: 18,
        alt: false,
        instructions:true
    }

    response = self.class.get('http://routes.ibikecph.dk/v1.1/fast/viaroute', query: options)
    raise TravelPlanner::ConnectionError unless response['route_summary']

    response['route_summary'].merge!({
        'type': leg.type,
        'departure_time': leg.departure_time,
        'arrival_time': leg.arrival_time
    })
    response
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

        location = self.class.get('/location/', query: query)
        raise TravelPlanner::ConnectionError unless location
        station = location['LocationList']['StopLocation'].detect{|s| s['name'] == point['name']}

        %w(y x).map{|coord| (station[coord].to_f / 10**6)}
      end
    end
  end
end
