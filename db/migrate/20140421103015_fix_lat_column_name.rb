class FixLatColumnName < ActiveRecord::Migration[4.2]
  def up
    rename_column :favourites, :lattitude, :latitude
    rename_column :routes, :from_lattitude, :from_latitude
    rename_column :routes, :to_lattitude, :to_latitude
  end

  def down
    rename_column :favourites, :latitude, :lattitude
    rename_column :routes, :from_latitude, :from_lattitude
    rename_column :routes, :to_latitude, :to_lattitude
  end
end
