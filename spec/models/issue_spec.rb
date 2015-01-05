require 'rails_helper'

RSpec.describe Issue, type: :model do
  it 'works' do
    i = Issue.create!(title: 'Moby Dick', body: 'Call me Ishmael')

    expect(i.title).to eq('Moby Dick')
  end
end
