class AddCoordinatesToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :coordinates, :text
  end
end
