class CreateBlogEntries < ActiveRecord::Migration
  def change
    create_table :blog_entries do |t|
      t.string   :title
      t.text     :body
      t.string   :image
      t.integer  :sticky
      t.integer  :comments_count
      t.timestamps
    end
  end
end
