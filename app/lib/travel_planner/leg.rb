class TravelPlanner::Leg
  include HTTParty
  def initialize(data)
    @data = data
    @coords = ref_coords
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

  def ref
    @ref ||= @data['JourneyDetailRef']['ref']
  end

  def coords
    @coords
  end

  private
  def ref_coords
    stops = HTTParty.get(ref)['JourneyDetail']['Stop']
    origin_stop = stops.detect {|s| s['name'] == origin['name']}
    destination_stop = stops.detect {|s| s['name'] == destination['name']}

    origin_coords = [origin_stop['x'].insert(2,'.').to_f, origin_stop['y'].insert(2,'.').to_f]
    destination_coords = [destination_stop['x'].insert(2,'.').to_f, destination_stop['y'].insert(2,'.').to_f]

    [origin_coords, destination_coords]
  end

  def parse_time
    format = '%d.%m.%y%H:%M'
    start_time =  DateTime.strptime(origin['date'] + origin['time'],format)
    end_time   =  DateTime.strptime(destination['date'] + destination['time'],format)
    ((end_time - start_time) * 1.days).floor
  end
end