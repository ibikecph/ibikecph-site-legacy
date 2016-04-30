class DropTracks < ActiveRecord::Migration
  def change
    drop_table :tracks
  end
end
