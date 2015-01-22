require 'rails_helper'

describe 'Users API' do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  context 'should not return' do
    it "user without token" do
      get "/api/users/#{@user.id}", {}, headers

      expect(response).to_not be_success
      expect(response).to have_http_status(403)
    end

    it 'all users' do
      get '/api/users', {}, headers

      expect(response).not_to be_success
      expect(response).to have_http_status(403)
    end
  end
end
