SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :home, t('menu.routes'), root_path, :highlights_on => /^\/(en)?$/
    #primary.item :about, t('menu.about'), about_path, :highlights_on => /^(\/en)?\/about/
  end
end