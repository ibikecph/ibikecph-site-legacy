class Coordinate < ActiveRecord::Base
  belongs_to :track

  validates :latitude,
            :format => { :with => /\A\d+(?:\.\d{0,6})?\z/ },
            :numericality => {:greater_than => 0, :less_than => 180}
  validates :longitude,
            :format => { :with => /\A\d+(?:\.\d{0,6})?\z/ },
            :numericality => {:greater_than => 0, :less_than => 180}

  validates_presence_of :seconds_passed,
                        :latitude,
                        :longitude

  def timestamp
    Time.at(self.track.timestamp.to_i + self.seconds_passed)
  end
end
