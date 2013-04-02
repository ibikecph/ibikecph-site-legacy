class RemoveAuthentications < ActiveRecord::Migration
  def up
    drop_table :authentications
  end

  def down
  end
end
