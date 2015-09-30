class AddSecondsPassedToCoordinates < ActiveRecord::Migration
  def change
    add_column :coordinates, :seconds_passed, :integer
  end
end
