class TravelPlanner
  require 'travel_planner/leg'

  include HTTParty

  base_uri ENV['REJSEPLANEN_API_URL']

  @headers = {'Content-Type' => 'application/json'}

  def self.get_journey(options={})
    trips = Rails.cache.fetch('journe', expires_in: 30.minutes) do
      get('/trips/', query: options,  headers: @headers )['TripList']['Trip']
    end

    format_trips trips
  end

  private

  def self.format_trips(trips)
    formatted_trips=[]

    trips.each do |trip|
      formatted_legs=[]

      trip['Leg'].each do |leg|
        formatted_legs.push (leg['type'] == 'BIKE') ? format_bike : format_train(leg)
      end

      formatted_trips.push formatted_legs
    end

    formatted_trips
  end

  def self.format_train(leg)
    current_leg = Leg.new leg
    current_trip = {}
    current_trip[:route_name] = [current_leg.origin['name'], current_leg.destination['name']]

    current_trip[:route_summary] = {
        end_point: current_leg.destination['name'],
        start_point: current_leg.origin['name'],
        total_time: current_leg.total_time
    }

    current_trip[:via_points] = current_leg.coords

    current_trip[:route_instructions] = build_route_instructions current_leg
    current_trip[:route_geometry] = Polylines::Encoder.encode_points(current_leg.coords)

    current_trip
  end

  # route_instructions structure
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
        loc: ['55.677567,12.569259','55.670627,12.558336'],
        z: 18,
        alt: false,
        instructions:true
    }
    disable_rails_query_string_format
    get("http://routes.ibikecph.dk/v1.1/fast/viaroute", query: options)
  end
end