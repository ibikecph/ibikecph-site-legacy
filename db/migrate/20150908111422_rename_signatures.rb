class RenameSignatures < ActiveRecord::Migration
  def change
    rename_column :tracks, :signature, :salted_signature
  end
end
