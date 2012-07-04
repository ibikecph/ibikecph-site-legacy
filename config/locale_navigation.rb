SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
  	[:da,:en].each do |l|
	    primary.item l, 
	      t( l, :locale=>l ),
	      url_for(:locale => (l == I18n.default_locale ? nil : l)), 
        :highlights_on => lambda{ I18n.locale == l }
  	end
  end
end