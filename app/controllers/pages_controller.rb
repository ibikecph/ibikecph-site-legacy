class PagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index,:ping,:terms,:qr]
  
	def index
	end

  def ping
    render :text => 'pong'
  end
  
  def fail
    raise "Raising an error for testing!" if current_user && current_user.role == 'super'
    render :nothing => true
  end
  
  def qr
    redirect_to root_path
  end
end
