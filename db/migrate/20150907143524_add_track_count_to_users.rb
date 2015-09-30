class AddTrackCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :track_count, :integer
  end
end
