class AddPrivacyTokenIdToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :privacy_token_id, :integer
  end
end
