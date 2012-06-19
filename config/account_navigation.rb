# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_class = :subnav
    primary.item :profile, 'Profile', account_path, :highlights_on => /^\/(account|account\/edit)$/
    primary.item :profile, 'Logins', account_path, :highlights_on => /^\/account\/(logins|emails|password)/
    primary.item :profile, 'Notifications', notifications_account_path, :highlights_on => /^\/account\/notifications/
  end
end