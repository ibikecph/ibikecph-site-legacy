require 'rails_helper'

describe 'Terms API', api: :v1 do

  context 'should' do
    it 'get terms' do
      get "/api/terms", {}, headers
      
      expect(response).to be_success
      expect(response).to have_http_status(200)

      p json
    end
  end
end
