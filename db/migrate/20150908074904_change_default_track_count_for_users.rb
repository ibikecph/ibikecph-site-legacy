class ChangeDefaultTrackCountForUsers < ActiveRecord::Migration
  def change
    change_column :users, :track_count, :integer, default: 0
  end
end
