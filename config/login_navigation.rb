# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    if current_user
      primary.item :account, current_user.name, account_path, :highlights_on => /^\/account/
      primary.item :logout, t('menu.logout'), destroy_user_session_path, :method => :delete
    else
      primary.item :signup, t('menu.signup'), new_registration_path(resource_name)
      primary.item :login, t('menu.login'), new_session_path(resource_name)
    end
  end
end


