class AddPositionToFavourites < ActiveRecord::Migration[4.2]
  def change
    add_column :favourites, :position, :integer, :default=>0
  end
end
