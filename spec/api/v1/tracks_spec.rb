require 'rails_helper'

describe 'Routes API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!

    @track = build :track
  end

  context 'should' do
    context 'when logged in' do
      it 'create track' do
        cord_count = 3

        sign_in @user

        attrs = attributes_for :track

        attrs[:coordinates_attributes] = Array.new(cord_count){ attributes_for :coordinate }

        post "/api/tracks", {track: attrs, auth_token: token}, headers

        expect(response).to be_succes
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')

        expect(json['data']).to have_key('count')
        expect(json['data']['count']).to eq(cord_count)

      end
    end
  end
end
