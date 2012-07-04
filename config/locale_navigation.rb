SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
#    primary.item :da, t(l,:locale=>:da), root_path, :highlights_on => lambda{ I18n.locale == l }
#    primary.item :en, t(l,:locale=>:en), root_path(:locate => :en), :highlights_on => lambda{ I18n.locale == l }

  	[:da,:en].each do |l|
  	  name = t(l,:locale=>l)
  	  locale = l unless l == I18n.default_locale
	    primary.item l, name, root_path(:locale => locale), :highlights_on => lambda{ I18n.locale == l }
  	end
  end
end