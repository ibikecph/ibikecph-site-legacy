class EmbedController < ApplicationController

  skip_before_filter :require_login
  layout 'embed'  

  def cykelsupersti
    render 'map/index'
  end  
end
