namespace :kortforsyningen do

  desc "Renew the ticket used to authenticate calls to 'kortforsyningen' geocoding api"
  task :renew_ticket => :environment do

		# fetch a new ticket from external api
		uri = URI.parse("https://services.kortforsyningen.dk/service?request=GetTicket&login=#{ENV.fetch('KMS_USERNAME')}&password=#{ENV.fetch('KMS_PSWD')}")
		response = Net::HTTP.get_response uri

		# we except tickets in a format like "dee75eb6d0e0911d5a3feee2d322ca78"
		if response.is_a?(Net::HTTPSuccess) and response.body =~ /\A[a-z0-9]{32}\Z/
			response.body

			# store new ticket
			ticket = KortforsyningenTicket.new code: response.body
			ticket.save!

			puts "Kortforsyningen ticket renewed: #{response.body}"

		  # destroy old tickets
		  KortforsyningenTicket.where("created_at < '#{1.hour.ago}'").delete_all
		else
			raise "Could not renew Kortforsyningen ticket, code: #{response.code}, body: #{response.body}"
		end
	end
end
