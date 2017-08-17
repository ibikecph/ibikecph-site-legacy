module ApiHelpers
  def sign_in(user)
    post '/api/login', 
      params: { user: { email: user.email, password: user.password } },
      headers: headers
  end

  def sign_out(user)
    delete '/api/logout', params: { user: user }, headers: headers
  end

  def token
    @token ||= JSON.parse(response.body)['data']['auth_token']
  end

  def signature
    @signature ||= JSON.parse(response.body)['data']['signature']
  end

  def json
    @json ||= json_newest
  end

  def json_newest
    JSON.parse(response.body)
  end

  module V1
    def headers
      { 'Accept' => 'application/vnd.ibikecph.v1' }
    end
  end
end
