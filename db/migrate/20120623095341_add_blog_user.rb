class AddBlogUser < ActiveRecord::Migration
  def change
    add_column :blog_entries, :user_id, :integer    
  end
end
