require 'rails_helper'

describe 'Journey API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  context 'should' do
    context 'when logged in' do
      it 'get journey' do
        sign_in @user

        journey = {
            options:{
              originId: 8600626,
              originCoordName: '\0',
              destCoordX: 12557000,
              destCoordY: 55672000,
              destCoordName: '\0',
              useBicycle: 1,
              maxCyclingDistanceDep: 20000,
              maxCyclingDistanceDest: 20000,
              format: 'json'
            }
        }

        get "/api/journey", { auth_token: token, journey: journey }, headers

        expect(response).to be_success
        expect(json.length).to eq(3)
        pp json
      end
    end
  end
end