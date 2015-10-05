class RemoveTrackCountFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :track_count
  end
end
