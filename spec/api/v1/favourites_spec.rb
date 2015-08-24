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

        get "/api/favourites", { auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data'].length).to eq(1)
        expect(json['data'].first['id']).to eq(@favourite.id)
      end

      it 'index own favourites when none' do
        sign_in @user

        get "/api/favourites", { auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data'].length).to eq(0)
      end

      it 'show route' do
        @user.favourites << @favourite

        sign_in @user

        get "/api/favourites/#{@favourite.id}", { auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@favourite.id)
      end

      it 'update favourite' do
        @user.favourites << @favourite

        sign_in @user

        newfavourite = {
          name: 'asdf42',
          address: 'asdfvej 42',
          lattitude: '55.123',
          longitude: '12.321'
        }

        patch "/api/favourites/#{@favourite.id}", { favourite: newfavourite, auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@favourite.id)
      end

      it 'create favourite' do
        sign_in @user

        attrs = attributes_for :favourite

        post "/api/favourites", { favourite: attrs, auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
      end

      it 'create favourite with lattitude' do
        sign_in @user

        attrs = {
            name:"Fav",
            address: "Vestergade 27-29, 1550 København V",
            lattitude: "55.677276",
            longitude: "12.569467",
            source: "favorite",
            sub_source: "favorite"
        }

        post "/api/favourites", { favourite: attrs, auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
      end

      it 'destroy favourite' do
        @user.favourites << @favourite

        sign_in @user

        delete "/api/favourites/#{@favourite.id}", { auth_token: token }, headers

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

        patch "/api/favourites/#{@favourite.id}", { favourite: newfavourite, auth_token: token }, headers

        # unauthorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end

      it 'destroy elses favourite' do
        @user.favourites << @favourite

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        delete "/api/favourites/#{@favourite.id}", { auth_token: token }, headers

        # unauthorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
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
