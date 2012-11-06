class AddUserTester < ActiveRecord::Migration
  def change
    add_column :users, :tester, :boolean, :default => false
  end
end
