class PagesController < ApplicationController
  
	def index
	end

  def ping
    render :text => 'pong'
  end
  
  def fail
    raise "Raising an error for testing!" if current_user && current_user.role == 'super'
    render :nothing => true
  end
  
end
