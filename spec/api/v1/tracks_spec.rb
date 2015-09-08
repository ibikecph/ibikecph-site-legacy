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

        5.times {post "/api/tracks", {track: attributes_for(:track), auth_token: token, signature: signature}, headers}

        get '/api/tracks', {auth_token: token, signature: signature}, headers

        expect(response).to be_success
        expect(json['data'].count).to eq(5)
      end
      it 'create track' do
        sign_in @user

        attrs = attributes_for :track_with_counts

        post "/api/tracks", {track: attrs, auth_token: token, signature: signature}, headers

        expect(response).to be_succes
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
        expect(json['data']['count']).to eq(attrs[:coord_count])
      end

      it 'destroy own track' do
        sign_in @user

        attrs = attributes_for :track_with_counts

        post "/api/tracks", {track: attrs, auth_token: token, signature: signature}, headers

        delete "/api/tracks/#{json['data']['id']}", { auth_token: token, signature: signature }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)
      end
    end
  end
  context 'should not' do
    context 'when logged in' do
      it 'create track with invalid coords' do
        attrs = attributes_for :track
        attrs[:coordinates] << {seconds_passed: 5, latitude:'hohoho', longitude:'lalala'}

        sign_in @user

        post "/api/tracks", {track: attrs, auth_token: token, signature: signature}, headers

        expect(response).to_not be_succes
        expect(response).to have_http_status(422)
      end

      it 'destroy others track' do
        track = create :track_with_counts

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        delete "/api/tracks/#{track.id}", { auth_token: token, signature: signature }, headers

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
