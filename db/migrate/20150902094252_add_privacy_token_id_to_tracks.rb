class AddPrivacyTokenIdToTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :tracks, :privacy_token_id, :integer
  end
end
