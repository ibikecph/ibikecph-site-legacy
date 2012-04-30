class PagesController < ApplicationController
  
  def index
  end
  
  def ping
    render :text => 'pong'
  end
  
end
