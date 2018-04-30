class FixLongitudeTypoInCoordinates < ActiveRecord::Migration[4.2]
  def change
    rename_column :coordinates, :longtitude, :longitude
  end
end
