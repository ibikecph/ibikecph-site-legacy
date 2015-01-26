require 'rails_helper'

describe 'Sessions API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  context 'should' do
    it 'sign up user' do
      newuser = {
        name: 'Foo Bar',
        email: 'foo@bar.com',
        email_confirmation: 'foo@bar.com',
        password: 'foobar',
        password_confirmation: 'foobar'
      }

      post '/api/users', { user: newuser }, headers

      expect(response).to be_success
      expect(response).to have_http_status(201)

      founduser = User.find_by email: newuser[:email]

      expect(founduser).not_to be_nil
    end

    it 'confirm user' do
      newuser = {
        name: 'Foo Bar',
        email: 'foo@bar.com',
        email_confirmation: 'foo@bar.com',
        password: 'foobar',
        password_confirmation: 'foobar'
      }

      post '/api/users', { user: newuser }, headers

      expect(response).to be_success
      expect(response).to have_http_status(201)

      post '/api/users/confirmation', { user: newuser }, headers

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'sign in user' do
      sign_in @user

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json['data']).to have_key('id')
      expect(json['data']['id']).to eq(@user.id)

      expect(json['data']).to have_key('auth_token')
      expect(json['data']['auth_token']).to eq(@user.authentication_token)
    end

    it 'sign out user' do
      sign_in @user

      expect(response).to be_success
      expect(response).to have_http_status(200)

      delete '/api/users/sign_out', { user: @user }, headers

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  context 'should not' do
    it 'sign in user with wrong password' do
      @user.password += '123'

      sign_in @user

      expect(response).not_to be_success
      expect(response).to have_http_status(401)
    end
  end
end
