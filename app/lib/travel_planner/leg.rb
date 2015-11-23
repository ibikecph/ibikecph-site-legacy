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

  def departure_time
    @departure_time ||= @data['Origin']['time']
  end

  def arrival_time
    @arrival_time ||= @data['Destination']['time']
  end

  def type
    @type ||= @data['type']
  end

  def total_time
    @total_time ||= parse_time
  end

  private
  def parse_time
    format = '%d.%m.%y%H:%M'
    start_time =  DateTime.strptime(origin['date'] + origin['time'],format)
    end_time   =  DateTime.strptime(destination['date'] + destination['time'],format)
    ((end_time - start_time) * 1.days).floor
  end
end