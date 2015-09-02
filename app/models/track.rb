class Track < ActiveRecord::Base
  belongs_to :privacy_token

  serialize :coordinates, JSON

  validates_presence_of :timestamp,
                        :to_name,
                        :from_name,
                        :coordinates

  def time_at_point i
    Time.at(self.timestamp.to_i + self.coordinates[i]['seconds_passed'].to_i)
  end
end
