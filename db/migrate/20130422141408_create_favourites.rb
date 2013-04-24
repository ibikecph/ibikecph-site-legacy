class CreateFavourites < ActiveRecord::Migration
  def change
    create_table :favourites do |t|
      t.references :user           
      t.string :name
      t.text :address
      t.string :lattitude
      t.string :longitude
      t.string :source
      t.string :sub_source
      t.timestamps
    end
  end
end
