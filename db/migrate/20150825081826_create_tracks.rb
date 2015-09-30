class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.date :start_date
      t.string :from_name
      t.string :to_name

      t.timestamps null: false
    end
  end
end
