require 'rails_helper'

describe 'Routes API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!

    @route = create :route
  end

  context 'should' do
    context 'when logged in' do
      it 'index own routes' do
        @user.routes << @route

        sign_in @user

        get "/api/routes", params: { auth_token: token }, headers: headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data'].length).to eq(1)
        expect(json['data'].first['id']).to eq(@route.id)
      end

      it 'show route' do
        @user.routes << @route

        sign_in @user

        get "/api/routes/#{@route.id}", params: { auth_token: token }, headers: headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@route.id)
      end

      it 'update route' do
        @user.routes << @route

        sign_in @user

        newroute = {
          from_name: 'asdf',
          from_latitude: '123',
          from_longitude: '123',

          to_name: 'oiup',
          to_latitude: '321',
          to_longitude: '321',

          start_date: Date.new
        }

        patch "/api/routes/#{@route.id}", params: { route: newroute, auth_token: token }, headers: headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@route.id)
      end

      it 'create route' do
        sign_in @user

        attrs = attributes_for :route

        post "/api/routes", params: { route: attrs, auth_token: token }, headers: headers

        expect(response).to be_success
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
      end

      it 'destroy route' do
        @user.routes << @route

        sign_in @user

        delete "/api/routes/#{@route.id}", params: { auth_token: token }, headers: headers

        expect(response).to be_success
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'should not' do
    context 'when logged in' do
      it 'update elses route' do
        @user.routes << @route

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        newroute = {
          from_name: 'asdf',
          from_latitude: '123',
          from_longitude: '123',

          to_name: 'oiup',
          to_latitude: '321',
          to_longitude: '321',

          start_date: Date.new
        }

        patch "/api/routes/#{@route.id}", params: { route: newroute, auth_token: token }, headers: headers

        # unauthorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end

      it 'destroy elses route' do
        @user.routes << @route

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        delete "/api/routes/#{@route.id}", params: { auth_token: token }, headers: headers

        # unauthorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end
    end

    context 'when not logged in' do
      it 'index routes' do
        get "/api/routes", params: {}, headers: headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'show route' do
        get "/api/routes/#{@route.id}", params: {}, headers: headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'create route' do
        attrs = attributes_for :route

        post "/api/routes", params: { route: attrs }, headers: headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'update route' do
        newroute = {
          from_name: 'asdf',
          from_latitude: '123',
          from_longitude: '123',

          to_name: 'oiup',
          to_latitude: '321',
          to_longitude: '321',

          start_date: Date.new
        }

        patch "/api/routes/#{@route.id}", params: { route: newroute }, headers: headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'destroy route' do
        @user.routes << @route

        delete "/api/routes/#{@route.id}", params: {}, headers: headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end
    end
  end
end
