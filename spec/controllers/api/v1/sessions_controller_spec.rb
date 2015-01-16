require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  include SessionHelpers

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!

    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'GET #create' do
    it "responds with success" do
      sign_in @user, type: :controller
    end

    it "responds with failure when wrong password" do
      post :create, user: { email: @user.email, password: @user.password + '123' }
      expect(response).not_to be_success
      expect(response).to have_http_status(401)
    end
  end

end
