class SetBlogCategories < ActiveRecord::Migration[4.2]
  def up
    BlogEntry.all.each do |entry|
      entry.category_list.add('news')
      entry.save!
    end
  end

  def down
  end
end
