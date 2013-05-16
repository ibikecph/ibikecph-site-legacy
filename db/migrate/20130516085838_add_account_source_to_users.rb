class AddAccountSourceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_source, :string, :default=>"ibikecph"
  end
end
