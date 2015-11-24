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
    format = '%d.%m.%y%H:%M%z'
    offset = '+0' + (ActiveSupport::TimeZone['Copenhagen'].utc_offset / 3600).to_s

    Time.strptime(point['date'] + point['time'] + offset,format).to_i
  end
end