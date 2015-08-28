class Track < ActiveRecord::Base
  belongs_to :user

  serialize :coordinates, JSON

  validates_presence_of :timestamp,
                        :to_name,
                        :from_name,
                        :coordinates
end
