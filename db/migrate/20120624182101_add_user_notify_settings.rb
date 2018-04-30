class AddUserNotifySettings < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :notify_by_email, :boolean, :default => true
  end

  def down
  end
end
