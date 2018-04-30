class CreateRoutes < ActiveRecord::Migration[4.2]
  def change
    create_table :routes do |t|
      t.references :user           
      t.string :from_name
      t.string :from_lattitude
      t.string :from_longitude
      t.string :to_name
      t.string :to_lattitude
      t.string :to_longitude
      t.datetime :start_date
      t.datetime :end_date
      t.text   :route_visited_locations
      t.boolean  :is_finished, :default => false
      t.timestamps
    end
  end
end
