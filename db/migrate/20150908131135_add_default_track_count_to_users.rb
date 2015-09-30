class AddDefaultTrackCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :track_count, :integer, default: 0
  end
end
