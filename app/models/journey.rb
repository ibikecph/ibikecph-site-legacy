class Journey < ActiveRecord::Base

  before_create :generate_token

  # fetch() makes syncronous http calls to rejseplanen's api,
  # and the time to complete the call is therefore unknown.
  # for this reason is should always be deferred to a background job.

  def fetch locations
    self.content = TravelPlanner.get_journey(locations).to_json
    self.ready = true
    save!
  end


  private

  def generate_token
    self.token = SecureRandom.base64
    self.ready = false
    true
  end

end
