class TravelPlanner
  include HTTParty

  base_uri ENV['REJSEPLANEN_API_URL']

  @headers = {'Content-Type' => 'application/json'}

  def self.get_journey(options={})
    trips = Rails.cache.fetch('journeys', expires_in: 30.minutes) do
      get('/trips/', query: options,  headers: @headers )['TripList']['Trip']
    end

    format_trips trips
  end

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

    current_trip[:route_geometry] = Polylines::Encoder.encode_points([[12.565562, 55.673063], [12.562083, 55.676011]])

    current_trip
  end

  def self.format_bike
    current_trip = get("http://routes.ibikecph.dk/v1.1/fast/viaroute?z=18&alt=false&loc=55.677567,12.569259&loc=55.670627,12.558336&instructions=true")
  end

  class Leg
    def initialize(data)
      @data = data
    end

    def origin
      @origin ||= @data['Origin']
    end

    def destination
      @destination ||= @data['Destination']
    end

    def total_time
      @total_time ||= parse_time
    end

    private
    def parse_time
      format = '%d.%m.%y%H:%M'
      start_time =  DateTime.strptime(origin['date'] + origin['time'],format)
      end_time =    DateTime.strptime(destination['date'] + destination['time'],format)
      (end_time - start_time) * 1.days
    end
  end

end