class AboutController < ApplicationController

  def intro
    @lookup = 'about.intro'
    render action: :show
  end

  def help
    @lookup = 'about.help'
    render action: :show
  end

  def api
    @lookup = 'about.api'
    render action: :show
  end

  def terms
    @lookup = 'about.terms'
    render action: :show
  end
end
