class AddSignatureToTrack < ActiveRecord::Migration
  def change
    add_column :tracks, :signature, :string
  end
end
