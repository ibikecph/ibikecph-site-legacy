require 'rails_helper'

describe 'Sessions API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  context 'should' do
    it 'sign in' do
      post '/api/users/sign_in', {
             user: { email: @user.email, password: @user.password }
           }, headers

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json['data']).to have_key('id')
      expect(json['data']['id']).to eq(@user.id)

      expect(json['data']).to have_key('auth_token')
      expect(json['data']['auth_token']).to eq(@user.authentication_token)
    end
  end

  context 'should not' do
    it 'sign in with wrong password' do
      post '/api/users/sign_in', {
             user: { email: @user.email, password: @user.password + '123' }
           }, headers

      expect(response).not_to be_success
      expect(response).to have_http_status(401)
    end
  end
end
