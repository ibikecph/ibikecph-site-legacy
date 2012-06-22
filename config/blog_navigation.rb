SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :blog, 'Latest', blog_entry_index_path, :highlights_on => /^\/blog$/
    primary.item :blog, 'Archive', archive_blog_entry_index_path, :highlights_on => /^\/blog\/archive/
    if can? :manage, BlogEntry
      primary.item :blog, 'New', new_blog_entry_path
    end
  end
end