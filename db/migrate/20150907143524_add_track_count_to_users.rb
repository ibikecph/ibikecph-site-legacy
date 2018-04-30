class AddTrackCountToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :track_count, :integer
  end
end
