SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :home, t('menu.routes'), root_path
    primary.item :blog, t('menu.blog'), blog_entry_index_path, :highlights_on => /^\/blog/
    primary.item :blog, t('menu.feedback'), issues_path
  end
end