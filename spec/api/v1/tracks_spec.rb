require 'rails_helper'

describe 'Tracks API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  context 'should' do
    context 'when logged in' do
      it 'index tracks' do
        sign_in @user

        (0...@user.track_count).each { |x| create :track, signature: signature, count: x }

        get '/api/tracks', {auth_token: token, signature: signature}, headers

        expect(response).to be_success
        expect(json['data'].count).to eq(@user.track_count)
      end
      it 'create track' do
        sign_in @user

        attrs = attributes_for :track, signature: signature

        post "/api/tracks", {track: attrs, auth_token: token}, headers

        expect(response).to be_succes
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
        expect(json['data']['count']).to eq(attrs[:coord_count])
      end

      it 'destroy own track' do
        sign_in @user

        (0...@user.track_count).each { |x| create :track, signature: signature, count: x }

        delete "/api/tracks/#{Track.last.id}", { auth_token: token, signature: signature }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)
      end
      it 'destroy all tracks' do
        sign_in @user

        (0...@user.track_count).each { |x| create :track, signature: signature, count: x }

        tracks = Track.all.count

        post delete_tracks_path, {auth_token: token, user:{password: @user.password}}

        expect(Delayed::Worker.new.work_off).to eq [1, 0]

        expect(Track.all.count).to eq(tracks - @user.track_count)
      end
    end
  end
  context 'should not' do
    context 'when logged in' do
      it 'destroy without valid signature' do
        sign_in @user

        track = create :track, signature: signature, count:0

        delete "/api/tracks/#{track.id}", { auth_token: token, signature: 'signature' }, headers

        # unauthorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)

      end
      it 'destroy non-existent track' do
        sign_in @user
        delete "/api/tracks/100", { auth_token: token, signature: signature }, headers

        expect(response).not_to be_success
        expect(response).to have_http_status(404)
      end
    end
    context 'when not logged in' do
      it 'destroy tracks' do
        delete "/api/tracks/1", { signature: 'signature' }, headers

        # unauthorized
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end
    end
  end
end
