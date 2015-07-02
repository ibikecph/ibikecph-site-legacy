module ApiHelpers
  def sign_in(user)
    post '/api/login', {
           user: { email: user.email, password: user.password }
         }, headers
  end

  def sign_out(user)
    delete '/api/logout', { user: user }, headers
  end

  def token
    @token ||= JSON.parse(response.body)['data']['auth_token']
  end

  def json
    @json ||= JSON.parse(response.body)
  end

  module V1
    def headers
      { 'Accept' => 'application/vnd.ibikecph.v1' }
    end
  end
end
