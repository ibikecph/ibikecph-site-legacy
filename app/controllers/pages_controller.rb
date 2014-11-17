class PagesController < ApplicationController

  before_filter :authenticate_user!, except: [:index, :ping, :terms, :qr]

  def index
  end

  def ping
    render text: 'pong'
  end

  def fail
    if current_user && current_user.role == 'super'
      raise 'Raising an error for testing!'
    end
    render nothing: true
  end

  def qr
    redirect_to root_path
  end
end
