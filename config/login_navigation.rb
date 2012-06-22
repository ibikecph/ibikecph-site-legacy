# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    if current_user
      primary.item :account, current_user.name, account_path, :highlights_on => /^\/account/
      primary.item :logout, "Logout", logout_path
    else
      primary.item :signup, "Sign Up", signup_path
      primary.item :login, "Login", login_path
    end
  end
end


