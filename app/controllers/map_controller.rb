class MapController < ApplicationController
  
  skip_before_filter :require_login
  layout 'map'
  
  def index
  end  
end
