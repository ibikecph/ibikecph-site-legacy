class RenameSignatures < ActiveRecord::Migration[4.2]
  def change
    rename_column :tracks, :signature, :salted_signature
  end
end
