require 'rails_helper'

describe 'Users API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  context 'should' do
    context 'when logged in' do
      it 'show user' do
        sign_in @user

        expect(response).to be_success
        expect(response).to have_http_status(200)

        get "/api/users/#{@user.id}", { auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@user.id)
      end

      it 'show other user' do
        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in @user

        get "/api/users/#{otheruser.id}", { auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(otheruser.id)
      end

      # it 'update user' do
      #   sign_in @user

      #   patch "/api/users", { user: @user }, headers

      #   expect(response).to be_success
      #   expect(response).to have_http_status(200)
      # end

      it 'destroy user' do
        sign_in @user

        delete "/api/users/#{@user.id}", { auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'should not' do
    context 'when logged in' do
      it 'index users' do
        sign_in @user

        get '/api/users', { auth_token: token }, headers

        # unautorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end

      it 'destroy elses user' do
        sign_in @user

        otheruser = create :user

        delete "/api/users/#{otheruser.id}", { auth_token: token }, headers

        # access denied
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end
    end

    context 'when not logged in' do
      it 'show user' do
        get "/api/users/#{@user.id}", {}, headers

        expect(response).to_not be_success
        expect(response).to have_http_status(403)
      end

      it 'index users' do
        get '/api/users', {}, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'destroy user' do
        delete "/api/users/#{@user.id}", {}, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end
    end
  end
end
