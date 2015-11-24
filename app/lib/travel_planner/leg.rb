class TravelPlanner::Leg
  def initialize(data)
    @data = data
  end

  def origin
    @origin ||= @data['Origin']
  end

  def destination
    @destination ||= @data['Destination']
  end

  def name
    @name ||= @data['name']
  end

  def type
    @type ||= @data['type']
  end

  def departure_time
    @departure_time ||= parse_time(origin)
  end

  def arrival_time
    @arrival_time ||= parse_time(destination)
  end

  def total_time
    @total_time ||= (arrival_time-departure_time)
  end

  private
  def parse_time(point)
    format = '%d.%m.%y%H:%M%Z'
    Time.zone = 'Copenhagen'
    zone = Time.zone.now.zone # a little hacky but Rails didn't seem to have any easier ways.
    Time.strptime(point['date'] + point['time'] + zone,format).to_i
  end
end