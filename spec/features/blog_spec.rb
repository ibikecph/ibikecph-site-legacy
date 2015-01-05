require 'rails_helper'

RSpec.describe 'blog page', type: :feature do
  it 'works' do
    visit '/'
    click_link I18n.t('menu.blog')
    expect(page).to have_content I18n.t('news.title')
  end
end
