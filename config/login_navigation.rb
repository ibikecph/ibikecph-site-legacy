# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    if current_user
      primary.item :account, current_user.name, account_path, :highlights_on => /^\/account/
      primary.item :logout, t('menu.logout'), logout_path
    else
      primary.item :signup, t('menu.signup'), signup_path
      primary.item :login, t('menu.login'), login_path
    end
  end
end


