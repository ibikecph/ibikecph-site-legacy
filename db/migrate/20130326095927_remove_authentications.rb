class RemoveAuthentications < ActiveRecord::Migration[4.2]
  def up
    drop_table :authentications
  end

  def down
  end
end
