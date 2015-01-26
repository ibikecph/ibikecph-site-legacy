module ApiHelpers
  def sign_in(user)
    post '/api/users/sign_in', {
           user: { email: user.email, password: user.password }
         }, headers
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
