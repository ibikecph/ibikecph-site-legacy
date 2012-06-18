class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
  
  
  private
  
  def set_locale
    if params[:locale]
      if I18n.available_locales.include?(params[:locale].to_sym)
        I18n.locale = params[:locale]
      else
        redirect_to root_path
      end
    else
      I18n.locale = I18n.default_locale
    end
  end

end
