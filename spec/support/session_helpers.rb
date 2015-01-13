module SessionHelpers
  include Devise::TestHelpers

  def sign_in(user, type: nil)
    return false if :type == nil

    if type == :controller
      @request.env['devise.mapping'] = Devise.mappings[:user]

      post :create, user: { email: @user.email, password: @user.password }
      expect(response).to be_success
      expect(response).to have_http_status(200)

    elsif type == :feature
      visit new_user_session_path

      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password

      click_button I18n.t('sessions.new.submit')

      expect(page).to have_content I18n.t('devise.sessions.signed_in')
    end
  end
end
