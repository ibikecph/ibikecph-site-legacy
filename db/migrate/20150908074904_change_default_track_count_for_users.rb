class ChangeDefaultTrackCountForUsers < ActiveRecord::Migration[4.2]
  def change
    change_column :users, :track_count, :integer, default: 0
  end
end
