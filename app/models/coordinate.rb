class Coordinate < ActiveRecord::Base
  belongs_to :track

  validates_presence_of :seconds_passed,
                        :latitude,
                        :longitude

  def timestamp
    Time.at(self.track.timestamp.to_i + self.seconds_passed)
  end
end
