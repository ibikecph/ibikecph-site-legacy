class TravelPlanner::Leg
  include HTTParty
  def initialize(data)
    @data = data
    @coords #= TravelPlanner::CoordSet.new(ref_coords)
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


  def parse_time
    format = '%d.%m.%y%H:%M'
    start_time =  DateTime.strptime(origin['date'] + origin['time'],format)
    end_time   =  DateTime.strptime(destination['date'] + destination['time'],format)
    ((end_time - start_time) * 1.days).floor
  end
end