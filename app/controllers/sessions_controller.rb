class SessionsController < ApplicationController  

  before_filter :find_auth_info, :only => :oath_create
  before_filter :oauth_login_existing_user, :only => :oath_create
  before_filter :oauth_link_to_current_user, :only => :oath_create
  before_filter :oauth_link_via_email, :only => :oath_create
  before_filter :oauth_check_existing_name, :only => :oath_create
  
  def existing
    if flash[:existing_user_id]
      @user = User.find flash[:existing_user_id]
      @provider = flash[:provider_name].titleize
      @emails = @user.authentications.emails.active
      @oauths = @user.authentications.oauths.active
    else
      redirect_to login_path
    end
  end
  
  def oath_setup
    render :nothing => true
  end

  def oath_create
    #raise auth.to_yaml
    user = User.create_with_omniauth! @auth
    copy_return_to
    reset_session    
    auto_login user
    logged_in welcome_account_path, :notice => "Logged in as #{user.name} using #{@auth["provider"].titleize}."  
  end

  def new
  end

  def new_and_return
    session[:return_to] = request.referer
    session[:return_to_saved_at] = Time.zone.now
    render :new
  end

  def create
    auth = Authentication.find_by_provider_and_uid 'email', params[:email]
    if auth && (params[:password].blank? == false) && auth.user.authenticate(params[:password])
      if auth.state == 'active' || auth.token_created_at > VERIFICATION_RESPITE.ago
        auto_login auth.user, :remember_me => params[:remember_me]
        copy_return_to
        logged_in account_path, :notice => "Logged in as #{auth.user.name}"
      else
        @email = auth.uid
        redirect_to unverified_emails_path, :alert => "Email #{auth.uid} not verified."
      end
    else
      flash.now.alert = "Email or password was invalid"
      render :new
    end
  end

  def destroy
    logout
    redirect_to root_url, :notice => "Logged out."
  end

  def setup
    render :nothing => true
  end

  #when running in dev mode, allow login without calling out to facebook
  def dev_login role=''
    if Rails.env.development? || Rails.env.staging?
      user = User.find_by_role!(role.to_s)

      session.clear
      session[:user_id] = user.id
      redirect_to root_path, :notice => "Developer mode log in as #{user.name} with role #{role}"
    else
      redirect_to root_path
    end
  end

  def user
    dev_login
  end

  def alt
    dev_login :alt
  end

  def staff
    dev_login :staff
  end

  def admin
    dev_login :admin
  end

  def super
    dev_login :super
  end

  def redirect_facebook
    redirect_to "http://facebook.com"
  end

  def failure
    if params[:message]= 'invalid_credentials'
      redirect_to (current_user ? account_path : root_path), :alert => "Login cancelled."
    else
      redirect_to (current_user ? account_path : root_path), :alert => "Could not log in: #{params[:message]}"
    end
  end
  
  private

  def find_auth_info
    @auth = request.env["omniauth.auth"]
  end

  def oauth_login_existing_user
    authentication = Authentication.find_by_provider_and_uid @auth["provider"], @auth["uid"]
    if authentication
      user = authentication.user
      if current_user
        if user == current_user
          redirect_to account_path, :notice => "#{@auth["provider"].titleize} account #{@auth['info']['name']} already added."
        else
          redirect_to account_path, :alert => "#{@auth["provider"].titleize} account #{@auth['info']['name']} belongs to user #{user.name}."          
        end
        return
      end
      copy_return_to
      reset_session    
      auto_login user
      logged_in account_path, :notice => "Logged in as #{user.name} using #{@auth["provider"].titleize} account #{@auth['info']['name']}."
    end
  end
  
  def oauth_link_to_current_user
    user = current_user
    if user
      add_oauth user
      copy_return_to
      reset_session
      auto_login user
      logged_in account_path, :notice => "Added login using #{@auth["provider"].titleize} account #{@auth['info']['name']}."
    end
  end
  
  def oauth_link_via_email
    if @auth['info']["email"]
      email = EmailAuthentication.find_by_uid @auth['info']["email"]
      if email
        user = email.user
        if email.state == 'active'
          add_oauth user
          copy_return_to
          reset_session    
          auto_login user
          logged_in account_path, :notice => "Logged in as #{user.name} using #{@auth["provider"].titleize} account #{@auth['info']['name']}."
        else
          flash[:existing_user_id] = user.id
          flash[:provider_name] = @auth["provider"]
          redirect_to existing_sessions_path
        end
      end
    end
  end

  def oauth_check_existing_name
    @user = User.find_by_name @auth['info']['name']
    if @user
      flash[:existing_user_id] = @user.id
      flash[:provider_name] = @auth["provider"]
      redirect_to existing_sessions_path
    end
  end
  
  def add_oauth user
    a = OAuthAuthentication.new :provider => @auth["provider"], :uid => @auth["uid"]
    a.user = user
    a.save!
    #user.add_email(@auth['info']['email'], :active) if @auth['info']['email'].present?
    a
  end
  
end
