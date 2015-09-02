require 'rails_helper'

describe 'Privacy Token API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  context 'should' do
    context 'when logged in' do
      it 'generate token' do
        sign_in @user

        attrs = attributes_for :privacy_token

        post '/api/privacy_tokens', {user: attrs, auth_token: token}, headers

        expect(response).to be_succes
        expect(json['data']).to have_key('signature')
        expect(json['data']['signature'].length).to eq(60)
      end
      it 'update token' do
        old_token = create         :privacy_token
        new_token = attributes_for :privacy_token_new

        sign_in @user

        get   '/api/privacy_tokens', {user: new_token, auth_token: token}, headers
        patch '/api/privacy_tokens', {user: new_token, auth_token: token}, headers

        expect(response).to be_succes
        expect(json['data']).to have_key('signature')
        expect(json['data']['signature'].length).to eq(60)
        expect(json['data']['signature']).to_not eq(old_token['signature'])
      end
    end
  end
end