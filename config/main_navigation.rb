SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :home, t('menu.routes'), root_path, :highlights_on => /^\/(en)?$/
    primary.item :blog, t('menu.blog'), blog_entry_index_path, :highlights_on => /^(\/en)?\/blog/
    primary.item :feedback, t('menu.feedback'), issues_path, :highlights_on => /^(\/en)?\/(feedback|corps)/
  end
end