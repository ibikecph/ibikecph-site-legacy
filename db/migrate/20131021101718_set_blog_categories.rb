class SetBlogCategories < ActiveRecord::Migration
  def up
    BlogEntry.all.each do |entry|
      entry.category_list.add('news')
      entry.save!
    end
  end

  def down
  end
end
