SimpleNavigation::Configuration.run do |navigation|
	supported_locales = [
		{ :locale => :dk, :name => 'Dansk'   },
		{ :locale => :en, :name => 'English' }
	]

  navigation.items do |primary|
  	supported_locales.each do |l|
	    primary.item l[:locale], l[:locale].to_s, "/#{l[:locale]}", :link => { :title => l[:name] }, :highlights_on => lambda{ I18n.locale == l[:locale] }
  	end
  end
end