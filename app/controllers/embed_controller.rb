class EmbedController < ApplicationController

  skip_before_action :require_login, raise: false
  layout 'embed'

  def cykelsupersti
    render 'map/index'
  end

end
