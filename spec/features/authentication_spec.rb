require 'rails_helper'

RSpec.describe 'Authentication:', type: :feature do

  before :all do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  before :each do
    visit '/'
  end

  describe 'User' do

    context 'should' do
      it 'sign up' do
        click_link I18n.t('menu.signup')

        expect(page).to have_content I18n.t('devise.registrations.new.title')
        expect(page).to have_content I18n.t('devise.registrations.new.body')

        fill_in 'user_name', with: 'Ahmed Halibibi'
        fill_in 'user_email', with: 'ahmed@halibibi.com'
        fill_in 'user_email_confirmation', with: 'ahmed@halibibi.com'
        fill_in 'user_password', with: 'ahmed123'
        fill_in 'user_password_confirmation', with: 'ahmed123'
        check 'user_terms'

        click_button I18n.t('devise.sessions.new.signup')

        expect(page).to have_content I18n.t('devise.registrations.signed_up_but_unconfirmed')
      end

      it 'sign in' do
        click_link I18n.t('menu.login')

        expect(page).to have_content I18n.t('devise.sessions.new.title')

        sign_in @user

        expect(page).to have_content I18n.t('devise.sessions.signed_in')
        expect(page).to have_content I18n.t('accounts.show.title')
      end

      it 'sign out' do
        sign_in @user

        click_link I18n.t('menu.logout')

        expect(page).to have_content I18n.t('devise.sessions.signed_out')
        expect(current_path).to eq(root_path)
      end
    end

    context 'should not' do
      it 'sign in with wrong password' do
        visit new_user_session_path

        fill_in 'user_email', with: @user.email
        fill_in 'user_password', with: @user.password + 'asdf'

        click_button I18n.t('sessions.new.submit')

        expect(page).to have_content I18n.t('devise.failure.invalid')
        expect(page).to have_link I18n.t('menu.login')
      end
    end
  end
end
