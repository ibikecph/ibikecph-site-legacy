class AddPositionToFavourites < ActiveRecord::Migration
  def change
    add_column :favourites, :position, :integer, :default=>0
  end
end
