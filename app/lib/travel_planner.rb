class TravelPlanner
  include HTTParty
  require 'travel_planner/leg'

  base_uri ENV['REJSEPLANEN_API_URL']

  def self.get_journey(options={})
    trips = Rails.cache.fetch('journe', expires_in: 30.minutes) do
      get('/trips/', query: options,  headers: {'Content-Type' => 'application/json'} )['TripList']['Trip']
    end

    format_trips trips
  end

  private

  def self.format_trips(trips)
    formatted_trips=[]

    trips.each do |trip|
      formatted_trips.push (trip['Leg'].map {|leg| (leg['type'] == 'BIKE') ? format_bike : format_train(leg)})
    end

    formatted_trips
  end

  # We're formatting the response so it mirrors our OSRM-routers bike response.
  def self.format_train(current_leg)
    leg = Leg.new current_leg
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
  def self.build_route_instructions(leg)
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

  def self.format_bike
    options = {
        loc: %w(55.677567,12.569259 55.670627,12.558336),
        z: 18,
        alt: false,
        instructions:true
    }

    # This enables us to send loc as an array.
    disable_rails_query_string_format
    get('http://routes.ibikecph.dk/v1.1/fast/viaroute', query: options)
  end
end