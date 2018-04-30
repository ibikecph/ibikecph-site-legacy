class DropCoordinates < ActiveRecord::Migration[4.2]
  def change
    drop_table :coordinates
  end
end
