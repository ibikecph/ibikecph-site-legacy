require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  describe 'GET #create' do
    it "responds with success" do
      sign_in @user
    end

    it "responds with failure when wrong password" do
      post :create, user: { email: @user.email, password: @user.password + '123' }
      expect(response).not_to be_success
      expect(response).to have_http_status(401)
    end
  end

end
