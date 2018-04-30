class AddBlogUser < ActiveRecord::Migration[4.2]
  def change
    add_column :blog_entries, :user_id, :integer    
  end
end
