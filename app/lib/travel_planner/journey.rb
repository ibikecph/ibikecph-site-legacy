class TravelPlanner::Journey
  def initialize(options)
    @coords = TravelPlanner::CoordSet.new options[:loc]
    @journey_data = fetch_journey_data options.merge(@coords.for_travel)
  end

  def routes
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
    total_duration = total_distance = total_distance_bike = 0

    legs = journey_data['Leg'].map do |leg_data|
      leg = TravelPlanner::Leg.new leg_data, @coords

      formatted_leg = case leg.type
      when 'BIKE', 'WALK'
        format_bike(leg)
      else
        format_public(leg)
      end

      total_duration      += formatted_leg[:duration]
      total_distance      += formatted_leg[:distance]
      total_distance_bike += formatted_leg[:distance] if leg.type == 'BIKE'

      formatted_leg
    end

    {
      duration:      total_duration,
      distance:      total_distance,
      distance_bike: total_distance_bike,
      legs: legs
    }
  end

  # We're formatting the response so it mirrors our OSRM-routers bike response.
  def format_public(leg)
    {
      summary:        leg.name,
      duration:       leg.duration,
      steps:          leg.steps,
      distance:       leg.distance,
      type:           leg.type,
      departure_time: leg.departure_time,
      arrival_time:   leg.arrival_time,
      start_point:    leg.origin['name'],
      end_point:      leg.destination['name'],
      geometry:       leg.geometry,
    }.with_indifferent_access
  end

  def format_bike(leg)
    options = {
      overview: 'full',
      alternatives: 'false',
      steps: 'true'
    }

    # TODO: Change this to OSRMv5
    response = TravelPlanner.get("https://routes.ibikecph.dk/v5/fast/route/#{leg.coords.for_osrm}", query: options)

    raise TravelPlanner::ConnectionError unless response['code'] == 'Ok'

    osrm_leg = response['routes'][0]['legs'][0]
    geometry = response['routes'][0]['geometry']
    hint     = response['waypoints'][1]['hint'] # destination hint

    osrm_leg.merge!({
      type:             leg.type,
      departure_time:   leg.departure_time,
      arrival_time:     leg.arrival_time,
      geometry:         geometry,
      destination_hint: hint
    }).with_indifferent_access
  end
end
