class Route < ActiveRecord::Base

  attr_accessible :from_name,
                  :from_lattitude,
                  :from_longitude,
                  :to_name,
                  :to_lattitude,
                  :to_longitude,
                  :route_geometry,
                  :route_instructions,
                  :route_summary,
                  :route_name,
                  :start_date,
                  :end_date,
                  :route_visited_locations,
                  :is_finished

  belongs_to :user

  validates_presence_of :from_name,
                        :from_lattitude,
                        :from_longitude,
                        :to_name,
                        :to_lattitude,
                        :to_longitude,
                        :start_date
  validates_presence_of :end_date,
                        :route_visited_locations,
                        if: lambda { |s| s.is_finished }

  scope :finished_routes, where('is_finished = true').order('created_at desc')
  scope :recent_routes, where('is_finished = false').order('created_at desc').limit(50)

  def finished_route?
    is_finished
  end

end
