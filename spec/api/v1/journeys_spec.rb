require 'rails_helper'

describe 'Journey API', api: :v1 do
  context 'should' do
    #todo make test more comprehensive
    it 'get journey' do
      get "/api/journey", { loc: %w(55.682061,12.571311 55.759048,12.458082) }, headers

      expect(response).to be_success
      expect(json).to have_key('journeys')
      expect(json['journeys'].length).to be >= 3
    end
  end
end