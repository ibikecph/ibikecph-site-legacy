class AddUserIdToTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :tracks, :user_id, :integer
  end
end
