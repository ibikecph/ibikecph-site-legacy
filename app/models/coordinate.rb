class Coordinate < ActiveRecord::Base
  belongs_to :track

  validates_presence_of :timestamp,
                        :latitude,
                        :longitude
end
