require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  include SessionHelpers

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  describe 'GET #show' do
    it "responds successfully" do
      # sign_in @user

      get :show, format: 'json,', id: @user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #index' do
    it "responds with unauthorized access" do
      #sign_in @user, type: :controller

      get :index

      expect(response).not_to be_success
      expect(response).to have_http_status(401)
    end
  end

end
