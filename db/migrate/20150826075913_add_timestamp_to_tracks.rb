class AddTimestampToTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :tracks, :timestamp, :integer
  end
end
