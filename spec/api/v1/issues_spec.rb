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

        get "/api/issues", params: { auth_token: token }, headers: headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data'].length).to eq(1)
        expect(json['data'].first['id']).to eq(@issue.id)
      end

      it 'show issue' do
        @user.reported_issues << @issue

        sign_in @user

        get "/api/issues/#{@issue.id}", params: { auth_token: token }, headers: headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@issue.id)
      end

      it 'create issue' do
        sign_in @user

        attrs = attributes_for :reported_issue

        post "/api/issues", params: { issue: attrs, auth_token: token }, headers: headers

        expect(response).to be_success
        expect(response).to have_http_status(201)

        expect(json['data']).to have_key('id')
      end
    end
  end

  context 'should not' do
    context 'when logged in' do
      it 'update issue' do
        @user.reported_issues << @issue

        sign_in @user

        newissue = {
          comment: 'foo',
          error_type: 'bar'
        }

        patch "/api/issues/#{@issue.id}", params: { issue: newissue, auth_token: token }, headers: headers

        # unauthorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end

      it 'destroy issue' do
        @user.reported_issues << @issue

        sign_in @user

        delete "/api/issues/#{@issue.id}", params: { auth_token: token }, headers: headers

        # unauthorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end

      it 'update elses issue' do
        @issue.user_id = @user.id

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        newissue = {
          comment: 'foo',
          error_type: 'bar'
        }

        patch "/api/issues/#{@issue.id}", params: { issue: newissue, auth_token: token }, headers: headers

        # not found
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end

      it 'destroy elses issue' do
        @issue.user_id = @user.id

        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in otheruser

        delete "/api/issues/#{@issue.id}", params: { auth_token: token }, headers: headers

        # not found
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end
    end

    context 'when not logged in' do
      it 'index issues' do
        get "/api/issues", params: {}, headers: headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'show issue' do
        get "/api/issues/#{@issue.id}", params: {}, headers: headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'create issue' do
        attrs = attributes_for :reported_issue

        post "/api/issues", params: { issue: attrs }, headers: headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'update issue' do
        newissue = {
          comment: 'foo',
          error_type: 'bar'
        }

        patch "/api/issues/#{@issue.id}", params: { issue: newissue }, headers: headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'destroy issue' do
        @issue.user_id = @user.id

        delete "/api/issues/#{@issue.id}", params: {}, headers: headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end
    end
  end
end
