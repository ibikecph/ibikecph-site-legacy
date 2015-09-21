require 'rails_helper'

describe 'Users API', api: :v1 do

  before :each do
    @user = build :user
    @user.skip_confirmation!
    @user.save!
  end

  context 'should' do
    context 'when logged in' do
      it 'show user' do
        sign_in @user

        expect(response).to be_success
        expect(response).to have_http_status(200)

        get "/api/users/#{@user.id}", { auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(@user.id)
      end

      it 'show other user' do
        otheruser = build :user
        otheruser.skip_confirmation!
        otheruser.save!

        sign_in @user

        get "/api/users/#{otheruser.id}", { auth_token: token }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('id')
        expect(json['data']['id']).to eq(otheruser.id)
      end

      # it 'update user' do
      #   sign_in @user

      #   patch "/api/users", { user: @user }, headers

      #   expect(response).to be_success
      #   expect(response).to have_http_status(200)
      # end

      it 'destroy user' do
        sign_in @user

        (0...@user.track_count).each { |x| create :track, signature: signature, count: x }

        delete "/api/users/#{@user.id}", { auth_token: token, user: {password: @user.password} }, headers

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(User.find_by_id(@user.id)).to eq nil

        tracks = Track.all.count

        expect(Delayed::Worker.new.work_off).to eq [1, 0]

        expect(Track.all.count).to eq(tracks - @user.track_count)
      end

      it 'add_password' do
        fb_user = create :user_with_facebook

        post '/api/users/add_password', {user:{password:'coolpassword'},
                                         auth_token: fb_user.authentication_token
                                        }, headers

        expect(response).to be_success
        expect(json_newest['data']['signature'].length).to eq(60)
      end

      it 'has_password' do
        fb_user = create :user_with_facebook

        post '/api/users/has_password', {auth_token: fb_user.authentication_token}, headers
        expect(json_newest['has_password']).to eq(false)

        fb_user.update_attributes password: 'coolpassword'

        post '/api/users/has_password', {auth_token: fb_user.authentication_token}, headers
        expect(json_newest['has_password']).to eq(true)
      end

      it 'change password and token' do
        user = {email:'person100@example.com',
                current_password: @user.password,
                password: 'password123',
                password_confirmation:'password123'}

        sign_in @user

        (0...@user.track_count).each { |x| create :track, signature: signature, count: x }

        put update_password_path, {user: user, auth_token: token}, headers

        expect(response).to redirect_to(account_path)
      end
    end
    context 'when not logged in' do
      it 'sign in' do
        sign_in @user

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json['data']).to have_key('signature')
        expect(json['data']['signature'].length).to eq(60)
      end
    end
  end

  context 'should not' do
    context 'when logged in' do
      it 'index users' do
        sign_in @user

        get '/api/users', { auth_token: token }, headers

        # unautorized
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end

      it 'destroy elses user' do
        sign_in @user

        otheruser = create :user

        delete "/api/users/#{otheruser.id}", { auth_token: token }, headers

        # access denied
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end
    end

    context 'when not logged in' do
      it 'show user' do
        get "/api/users/#{@user.id}", {}, headers

        expect(response).to_not be_success
        expect(response).to have_http_status(403)
      end

      it 'index users' do
        get '/api/users', {}, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end

      it 'destroy user' do
        delete "/api/users/#{@user.id}", {}, headers

        # not logged in
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end
    end
  end
end
