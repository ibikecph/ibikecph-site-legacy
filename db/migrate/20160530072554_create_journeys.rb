class CreateJourneys < ActiveRecord::Migration[5.0]
  def change
    create_table :journeys do |t|
      t.string :token
      t.boolean :ready
      t.text :content
      t.timestamps
    end
  end
end
