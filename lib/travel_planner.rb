class TravelPlanner
  include HTTParty

  base_uri ENV['REJSEPLANEN_API_URL']

  @headers = {'Content-Type' => 'application/json'}

  def self.get_journey(options={})
    pp journey = get('/trips/', query: options,  headers: @headers )['TripList']['Trip']
  end

end