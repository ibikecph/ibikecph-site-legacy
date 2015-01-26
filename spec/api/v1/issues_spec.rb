require 'rails_helper'

describe 'Issues API', api: :v1 do

  before :each do
    @issue = create :reported_issue
  end

  context 'should return' do
    it 'all issues' do

      get "/api/issues", {}, headers

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json['data'].count).to eq(1)
    end

    it 'correct issue' do

      get "/api/issues/#{@issue.id}", {}, headers

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json['data']).to have_key('id')
      expect(json['data']['id']).to eq(@issue.id)
    end
  end
end
