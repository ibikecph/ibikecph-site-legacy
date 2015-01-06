require 'rails_helper'

RSpec.describe 'user', type: :feature do
  before :all do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  before :each do
    visit '/'
  end

  it 'can sign in' do
    click_link I18n.t('menu.login')

    expect(page).to have_content I18n.t('sessions.new.title')

    sign_in @user

    expect(page).to have_content I18n.t('accounts.show.title')
  end
end
