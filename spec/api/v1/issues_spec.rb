require 'rails_helper'

describe 'Issues API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!

    @issue = create :reported_issue
  end

  context 'should' do
    context 'when logged in' do
      it 'index own issues' do
        @issue.user_id = @user.id

        sign_in @user

        get "/api/issues", {}, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data'].length).to eq(1)
        expect(json['data'].first['id']).to eq(@issue.id)
      end

      it 'show issue' do
        @issue.user_id = @user.id

        sign_in @user

        get "/api/issues/#{@issue.id}", {}, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@issue.id)
      end

      it 'update issue' do
        @issue.user_id = @user.id

        sign_in @user

        newissue = {
          comment: 'foo',
          error_type: 'bar'
        }

        patch "/api/issues/#{@issue.id}", { issue: newissue }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@issue.id)
      end

      it 'create issue' do
        sign_in @user

        attrs = attributes_for :reported_issue

        post "/api/issues", { issue: attrs }, headers

        expect(response).to be_success
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
      end

      it 'destroy issue' do
        @issue.user_id = @user.id

        sign_in @user

        delete "/api/issues/#{@issue.id}", {}, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'should not' do
    context 'when logged in' do
      it 'update elses issue' do
        @issue.user_id = @user.id

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        newissue = {
          comment: 'foo',
          error_type: bar
        }

        patch "/api/issues/#{@issue.id}", { issue: newissue }, headers

        # not found
        expect(response).not_to be_success
        expect(response).to have_http_status(404)
      end

      it 'destroy elses issue' do
        @issue.user_id = @user.id

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        delete "/api/issues/#{@issue.id}", {}, headers

        # not found
        expect(response).not_to be_success
        expect(response).to have_http_status(404)
      end
    end

    context 'when not logged in' do
      it 'index issues' do
        get "/api/issues", {}, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'show issue' do
        get "/api/issues/#{@issue.id}", {}, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'create issue' do
        attrs = attributes_for :reported_issue

        post "/api/issues", { issue: attrs }, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'update issue' do
        newissue = {
          comment: 'foo',
          error_type: 'bar'
        }

        patch "/api/issues/#{@issue.id}", { issue: newissue }, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'destroy issue' do
        @issue.user_id = @user.id

        delete "/api/issues/#{@issue.id}", {}, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end
    end
  end
end
