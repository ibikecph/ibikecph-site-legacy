class MapController < ApplicationController

  #skip_before_action :require_login
  layout 'map'

  def index
  	ticket = KortforsyningenTicket.last
  	if ticket
			@kortforsyningen_ticket = ticket.code
		end
  end

end
