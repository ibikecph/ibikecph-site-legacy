module FeatureHelpers
  module Session
    def sign_in(user)
      visit new_user_session_path

      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password

      click_button I18n.t('sessions.new.submit')

      expect(page).to have_content I18n.t('devise.sessions.signed_in')
    end
  end
end
