class RemoveTrackCountFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :track_count
  end
end
