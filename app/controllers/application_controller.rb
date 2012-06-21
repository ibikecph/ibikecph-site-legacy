class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
  helper_method :current_user, :auth_link
  
  def route_not_found
    respond_to do |format|
      format.html { render 'errors/route_not_found', :status => :not_found }
      format.any { render :nothing => true, :status => :not_found }
    end
  end
  
  private 
  
  #unless Rails.application.config.consider_all_requests_local
  #  rescue_from Exception, :with => :internal_error
  #  rescue_from ActionController::UnknownController, :with => :route_not_found
  #  rescue_from ActionController::UnknownAction, :with => :route_not_found
  #  rescue_from ActionController::MethodNotAllowed, :with => :invalid_method
  #  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  #  rescue_from CanCan::AccessDenied, :with => :access_denied
  #  #note: can't yet catch ActionController::RoutingError in rails 3.
  #  #we're using a catch-all route instead.
  #end
  
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

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
    #FIXME should check user.remember_me_token_saved_at to see if the token has expired
  rescue
  end

  def require_login
    unless current_user
      save_return_to
      redirect_to login_path, :notice => 'Please login first.' 
    end
  end
  
  def auto_login user, options={}
    user.generate_token :auth_token
    if options[:remember_me]
      cookies.permanent[:auth_token] = user.auth_token
      user.remember_me_token_saved_at = Time.zone.now
    else
      cookies[:auth_token] = user.auth_token
    end
    user.save!
  end

  def logout
    if current_user
      current_user.clear_token :auth_token
      current_user.save!
      @current_user = nil
    end
    cookies.delete(:auth_token)
  end
  
  def save_return_to
    session[:return_to] = request.url
    session[:return_to_saved_at] = Time.zone.now
  end
  
  def copy_return_to
    @return_to = session[:return_to]
    @return_to_saved_at = session[:return_to_saved_at]
  end

  def logged_in default_path, options={}
    #use saved location unless it's outdated
    return_to = @return_to if @return_to && @return_to_saved_at && @return_to_saved_at > 5.minute.ago
    path = return_to || default_path || root_path
    @return_to = session[:return_to] = nil
    @return_to_saved_at = session[:return_to_saved_at] = nil
    redirect_to path, :notice => options[:notice] || "Logged in."
  #rescue nil
  #  redirect_to root_path, :notice => "Logged in."    
  end
      
end
