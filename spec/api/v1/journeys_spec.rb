require 'rails_helper'

# TODO
# tests shouldn't call external API's
# instead we should stub/mock the calls, see e.g.
# https://robots.thoughtbot.com/how-to-stub-external-services-in-tests

describe 'Journey API', api: :v1 do
  context 'should' do
    #todo make test more comprehensive
    it 'get journey' do
      # work queue should be empty
      expect(Delayed::Job.count).to eq(0)
      expect(Journey.count).to eq(0)
      
      # initiate journey plan, should get token back
      post "/api/journeys", { loc: ['55.677516,12.569641','55.671671,12.521519'] }, headers
      json = JSON.parse(response.body)
      expect(response).to be_success
      expect(json.length).to eq 1
      token = json["token"]
      expect(token).to be_a(String)

      # work queue should now contain one item
      expect(Delayed::Job.count).to eq(1)
      expect(Journey.count).to eq(1)
      journey = Journey.last
      expect( journey.token).to eq( token )
      expect( journey.ready).to eq( false )

      # poll result using token - should return 422, "not ready"
      get "/api/journeys/#{CGI.escape token}", {}, headers
      json = JSON.parse(response.body)
      expect(response.status).to eq(422)
      expect(json.length).to eq 1
      expect(json["error"]).to eq("not ready")  

      # poll using invalid token should return 404, "not found"
      get "/api/journeys/99999999999", {}, headers
      json = JSON.parse(response.body)
      expect(response.status).to eq(404)
      expect(json["error"]).to eq("not found")  

      # run jobs
      expect(Delayed::Worker.new.work_off).to eq( [1,0] )     # returns [successes, failures]

      # poll result using token - should now return 200, with the travel plan as content
      get "/api/journeys/#{CGI.escape token}", {}, headers
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(json.length).to eq 3
      expect(json[0]).to have_key('journey')
      expect(json[0]).to have_key('journey_summary')
    end
  end
end