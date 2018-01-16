class DropOutdatedTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :issues
    drop_table :blog_entries
    drop_table :votes
    drop_table :comments
    drop_table :follows
    drop_table :taggings
    
  end
end
