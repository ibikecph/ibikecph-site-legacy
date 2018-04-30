class DropTracks < ActiveRecord::Migration[4.2]
  def change
    drop_table :tracks
  end
end
