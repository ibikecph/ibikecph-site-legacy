class AddTrackIdToCoordinate < ActiveRecord::Migration[4.2]
  def change
    add_column :coordinates, :track_id, :integer
  end
end
