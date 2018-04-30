class AddCoordinatesToTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :tracks, :coordinates, :text
  end
end
