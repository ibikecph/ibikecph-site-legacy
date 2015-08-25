class FixLongitudeTypoInCoordinates < ActiveRecord::Migration
  def change
    rename_column :coordinates, :longtitude, :longitude
  end
end
