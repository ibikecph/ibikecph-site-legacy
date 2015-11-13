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
              coords: [55.682061,12.571311,55.759048,12.458082],
              originCoordName: '\0',
              destCoordName: '\0',
              useBicycle: 1,
              maxCyclingDistanceDep: 20000,
              maxCyclingDistanceDest: 20000,
              format: 'json'
            }
        }

        get "/api/journey", { auth_token: token, journey: journey }, headers

        expect(response).to be_success
        pp json
        expect(json.length).to eq(3)
      end
    end
  end
end