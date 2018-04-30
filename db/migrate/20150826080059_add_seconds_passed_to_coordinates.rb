class AddSecondsPassedToCoordinates < ActiveRecord::Migration[4.2]
  def change
    add_column :coordinates, :seconds_passed, :integer
  end
end
