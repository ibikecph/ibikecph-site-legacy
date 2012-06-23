class PagesController < ApplicationController
  
  def ping
    render :text => 'pong'
  end
  
  def feedback
  end
  
end
