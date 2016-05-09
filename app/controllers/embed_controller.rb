class EmbedController < ApplicationController

  skip_before_filter :require_login, raise: false
  layout 'embed'

  def cykelsupersti
    render 'map/index'
  end

end
