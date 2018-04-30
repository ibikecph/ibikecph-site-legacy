class AddAccountSourceToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :account_source, :string, :default=>"ibikecph"
  end
end
