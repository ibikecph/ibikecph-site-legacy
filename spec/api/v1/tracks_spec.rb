require 'rails_helper'

describe 'Tracks API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!

    @track         = create :track_with_coords
    @privacy_token = create :privacy_token
  end

  context 'should' do
    context 'when logged in' do
      it 'create track' do
        attrs = attributes_for :track

        sign_in @user

        post "/api/tracks", {track: attrs, auth_token: token}, headers

        expect(response).to be_succes
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
        expect(json['data']['count']).to eq(0)

      end

      it 'create track with coords' do
        attrs = attributes_for :track_with_coords
        attrs[:count]=5

        sign_in @user

        post "/api/tracks", {track: attrs, auth_token: token, signature: @privacy_token.signature}, headers

        expect(response).to be_succes
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
        expect(json['data']['count']).to eq(5)
      end

      it 'destroy own track' do
        @privacy_token.tracks << @track

        sign_in @user

        delete "/api/tracks/#{@track.id}", { auth_token: token, signature: @privacy_token.signature }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      context 'and user has privacy token' do
        it 'show tracks' do
          attrs = attributes_for :track_with_coords
          attrs[:count]=5

          sign_in @user

          3.times { post "/api/tracks", {track: attrs, auth_token: token}, headers }

          get "/api/tracks/", {auth_token: token, signature: '3ECCRWkkjjvD6cV7_7yzCw'}, headers
        end
      end
    end
  end
  context 'should not' do
    context 'when logged in' do
      it 'create track with invalid coords' do
        attrs = attributes_for :track_with_coords
        attrs[:coordinates_attributes] << {seconds_passed: 5, latitude:'hohoho', longitude:'lalala'}

        sign_in @user

        post "/api/tracks", {track: attrs, auth_token: token}, headers

        expect(response).to_not be_succes
        expect(response).to have_http_status(422)
      end

      it 'destroy others track' do
        @user.tracks << @track

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        delete "/api/tracks/#{@track.id}", { auth_token: token }, headers

        # unauthorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)

      end
    end
  end
end
