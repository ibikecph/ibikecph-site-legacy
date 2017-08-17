require 'rails_helper'

describe 'Base API', api: :v1 do

  context 'should' do
    it 'be reached with correct headers' do
      get "/api/users", params: {}, headers: headers

      expect(response).not_to be_nil
    end
  end

  context 'should not' do
    it 'be reached without correct headers' do
      expect{get "/api/users"}.to raise_error(ActionController::RoutingError)
    end
  end

end
