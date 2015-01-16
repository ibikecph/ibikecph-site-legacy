module ControllerHelpers
  module Session
    def sign_in(user)
      post :create, user: { email: user.email, password: user.password }
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end
end
