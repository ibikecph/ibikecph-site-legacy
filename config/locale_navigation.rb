SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
  	[:da,:en].each do |l|
  	  name = t(l,:locale=>l)
	    primary.item l, name, "/#{l}", :link => { :title => name }, :highlights_on => lambda{ I18n.locale == l }
  	end
  end
end