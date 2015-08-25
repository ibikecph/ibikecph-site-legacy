class Track < ActiveRecord::Base
  belongs_to :user
  has_many :coordinates

  accepts_nested_attributes_for :coordinates

  validates_presence_of :start_date,
                        :to_name,
                        :from_name

end
