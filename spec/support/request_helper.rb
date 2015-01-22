module RequestHelpers
  def headers
    { 'Accept' => "application/vnd.ibikecph.v1" }
  end

  def json
    @json ||= JSON.parse(response.body)
  end
end
