require 'rails_helper'

describe 'Tracks API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  context 'should' do
    context 'when logged in' do
      it 'generate token' do
        sign_in @user

        expect(response).to be_succes
        expect(json['data']).to have_key('signature')
        expect(json['data']['signature'].length).to eq(60)
      end

      it 'index tracks' do
        sign_in @user

        3.times do
          track = attributes_for(:track)
          track[:signature] = signature
          post "/api/tracks", {track: track, auth_token: token}, headers
        end

        get '/api/tracks', {auth_token: token, signature: signature}, headers

        expect(response).to be_success
        expect(json['data'].count).to eq(3)
      end
      it 'create track' do
        sign_in @user

        attrs = attributes_for :track_with_counts
        attrs[:signature] = signature

        post "/api/tracks", {track: attrs, auth_token: token}, headers

        expect(response).to be_succes
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
        expect(json['data']['count']).to eq(attrs[:coord_count])
      end

      it 'destroy own track' do
        sign_in @user

        attrs = attributes_for :track_with_counts
        attrs[:signature] = signature

        post "/api/tracks", {track: attrs, auth_token: token}, headers

        delete "/api/tracks/#{json['data']['id']}", { auth_token: token, signature: signature }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)
      end
    end
  end
  context 'should not' do
    context 'when logged in' do
      it 'destroy without valid signature' do
        sign_in @user

        attrs = attributes_for :track
        attrs[:signature] = signature

        post "/api/tracks", {track: attrs, auth_token: token}, headers

        delete "/api/tracks/#{json['data']['id']}", { auth_token: token, signature: 'signature' }, headers

        # unauthorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)

      end
      # it 'destroy non-existent track' do
      #   sign_in @user
      #
      #   delete "/api/tracks/100", { auth_token: token, signature: signature }, headers
      #
      #   p json
      # end
    end
  end
end
