class AddTimestampToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :timestamp, :integer
  end
end
