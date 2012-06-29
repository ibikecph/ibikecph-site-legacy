class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
  helper_method :current_user, :auth_link
  
  unless Rails.application.config.consider_all_requests_local
    rescue_from CanCan::AccessDenied, :with => :error_forbidden
  end
   
  def error_forbidden
    render 'errors/forbidden', :status => :forbidden rescue last_chance
  end
  
  #these error handlers are called from rack middleware, see routes.rb
  def error_route_not_found
    render 'errors/route_not_found', :status => :not_found rescue last_chance
  end
  
  def error_internal_error    
    render 'errors/internal_error' rescue last_chance
  end
    
  private 
  
  def last_chance
    #we're at the end of the line. render something with mimimal risk of throwing another exception
    render :file => 'public/500.html', :layout => false
  end
  
  def set_locale
    if params[:locale]
      if I18n.available_locales.include?(params[:locale].to_sym)
        I18n.locale = params[:locale]
        cookies[:locale] = {
          :value => params[:locale],
          :expires => Time.now + 365*24*60*60
        }
      end
      redirect_to root_path
    else
      locale = cookies[:locale]

      if locale and locale.size < 10 and I18n.available_locales.include? locale.to_sym
        I18n.locale = locale
      else
        I18n.locale = 'en'
      end
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
  
  def ta key, *args
    if key[0]=='.'
      self.class.to_s =~ /(.*)Controller/
      base = [$1,self.action_name].join('.').downcase
  	  t [base,key].join('.'), *args
  	else
  	  t key, *args
  	end
	end

  def i18n_action
  end

end
