class Track < ActiveRecord::Base
  belongs_to :user
  has_many :coordinates, dependent: :destroy

  accepts_nested_attributes_for :coordinates

  validates_presence_of :timestamp,
                        :to_name,
                        :from_name



end
