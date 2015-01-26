require 'rails_helper'

describe 'Issues API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!

    @issue = create :reported_issue
  end

  context 'should' do
    context 'when not logged in' do
      it 'index all issues' do
        get "/api/issues", {}, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data'].count).to eq(1)
      end

      it 'show issue' do
        get "/api/issues/#{@issue.id}", {}, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@issue.id)
      end

      it 'create issue' do
        attrs = attributes_for :reported_issue

        post '/api/issues', { issue: attrs }, headers

        expect(response).to be_success
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
      end

      it 'delete issue' do
        @issue.save!

        delete "/api/issues/#{@issue.id}", {}, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)
      end
    end
  end
end
