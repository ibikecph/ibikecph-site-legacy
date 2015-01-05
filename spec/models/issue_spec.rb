require 'rails_helper'

RSpec.describe Issue, type: :model do
  it 'works' do
    i = create(:issue)

    expect(i.title).to eq('Moby Dick')
  end
end
