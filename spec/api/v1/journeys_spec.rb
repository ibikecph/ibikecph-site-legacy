require 'rails_helper'

describe 'Journey API', api: :v1 do
  context 'should' do
    #todo make test more comprehensive
    it 'get journey' do
      get "/api/journey", { loc: %w(55.677516,12.569641 55.671671,12.521519) }, headers

      expect(response).to be_success
      expect(json).to have_key('journeys')
      expect(json['journeys'].length).to be >= 3
    end
  end
end