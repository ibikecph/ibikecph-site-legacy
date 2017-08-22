class MapController < ApplicationController

  #skip_before_action :require_login
  layout 'map'

  def index
  	@kortforsyningen_ticket = KortforsyningenTicket.last.code
  end

end
