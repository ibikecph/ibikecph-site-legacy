require 'rails_helper'

describe 'Favourites API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!

    @favourite = create :favourite
  end

  context 'should' do
    context 'when logged in' do
      it 'index own favourites' do
        @user.favourites << @favourite

        sign_in @user

        get "/api/favourites", {}, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data'].length).to eq(1)
        expect(json['data'].first['id']).to eq(@favourite.id)
      end

      it 'show route' do
        @user.favourites << @favourite

        sign_in @user

        get "/api/favourites/#{@favourite.id}", {}, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@favourite.id)
      end

      it 'update favourite' do
        @user.favourites << @favourite

        sign_in @user

        newfavourite = {
          from_name: 'asdf',
          from_latitude: '123',
          from_longitude: '123',

          to_name: 'oiup',
          to_latitude: '321',
          to_longitude: '321',

          start_date: Date.new
        }

        patch "/api/favourites/#{@favourite.id}", { favourite: newfavourite }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@favourite.id)
      end

      it 'create favourite' do
        sign_in @user

        attrs = attributes_for :favourite

        post "/api/favourites", { favourite: attrs }, headers

        expect(response).to be_success
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
      end

      it 'destroy favourite' do
        @user.favourites << @favourite

        sign_in @user

        delete "/api/favourites/#{@favourite.id}", {}, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'should not' do
    context 'when logged in' do
      it 'update elses favourite' do
        @user.favourites << @favourite

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        newfavourite = {
          from_name: 'asdf',
          from_latitude: '123',
          from_longitude: '123',

          to_name: 'oiup',
          to_latitude: '321',
          to_longitude: '321',

          start_date: Date.new
        }

        patch "/api/favourites/#{@favourite.id}", { favourite: newfavourite }, headers

        # not found
        expect(response).not_to be_success
        expect(response).to have_http_status(404)
      end

      it 'destroy elses favourite' do
        @user.favourites << @favourite

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        delete "/api/favourites/#{@favourite.id}", {}, headers

        # not found
        expect(response).not_to be_success
        expect(response).to have_http_status(404)
      end
    end

    context 'when not logged in' do
      it 'index favourites' do
        get "/api/favourites", {}, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'show favourite' do
        get "/api/favourites/#{@favourite.id}", {}, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'create favourite' do
        attrs = attributes_for :favourite

        post "/api/favourites", { favourite: attrs }, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'update favourite' do
        newfavourite = {
          name: 'Fav2',
          address: 'Vestergade 20C, 1550 Kobenhavn V',
          latitude: '123',
          longitude: '321'
        }

        patch "/api/favourites/#{@favourite.id}", { favourite: newfavourite }, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'destroy favourite' do
        @user.favourites << @favourite

        delete "/api/favourites/#{@favourite.id}", {}, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end
    end
  end
end
