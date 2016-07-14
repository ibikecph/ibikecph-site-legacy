class TravelPlanner::Journey
  def initialize(options)
    @coords = TravelPlanner::CoordSet.new options[:loc]
    @journey_data = fetch_journey_data options.merge(@coords.for_travel)
  end

  def trips
    format_journeys @journey_data
  end

  private
  def fetch_journey_data(query)
    response = TravelPlanner.get('/trips/', query: query)
    response ? response['TripList']['Trip'] : raise(TravelPlanner::ConnectionError)
  end

  def format_journeys(journey_data)
    journey_data.first(3).map {|journey| format_legs(journey) }
  end

  def format_legs(journey_data)
    total_time = total_distance = total_bike_distance = 0

    journey = journey_data['Leg'].map do |leg_data|
      leg = TravelPlanner::Leg.new leg_data, @coords

      formatted_leg = case leg.type
      when 'BIKE', 'WALK'
        format_bike(leg)
      else
        format_public(leg)
      end

      total_time          += formatted_leg['route_summary']['total_time']
      total_distance      += formatted_leg['route_summary']['total_distance']
      total_bike_distance += formatted_leg['route_summary']['total_distance'] if leg.type == 'BIKE'

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

  # We're formatting the response so it mirrors our OSRM-routers bike response.
  def format_public(leg)
    { route_name: [
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

    # TODO: Change this to OSRMv5
    response = TravelPlanner.get('https://routes.ibikecph.dk/v1.1/fast/viaroute', query: options)

    raise TravelPlanner::ConnectionError unless response['status'] == 0 || response['status'] == 200

    response['route_summary'].merge!({
        'type': leg.type,
        'departure_time': leg.departure_time,
        'arrival_time': leg.arrival_time
    })
    response
  end
end
