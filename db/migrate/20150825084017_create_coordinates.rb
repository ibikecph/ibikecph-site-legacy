class CreateCoordinates < ActiveRecord::Migration
  def change
    create_table :coordinates do |t|
      t.time :time
      t.decimal :latitude
      t.decimal :longtitude

      t.timestamps null: false
    end
  end
end
