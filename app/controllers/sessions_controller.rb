class SessionsController < ApplicationController

  skip_before_filter :require_login
  before_filter :find_auth_info, only: :oath_create
  before_filter :oauth_login_existing_user, only: :oath_create
  before_filter :oauth_link_to_current_user, only: :oath_create
  before_filter :oauth_link_via_email, only: :oath_create
  before_filter :oauth_check_existing_name, only: :oath_create

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

  def new
  end

  def new_and_return
    session[:return_to] = request.referer
    session[:return_to_saved_at] = Time.zone.now
    render :new
  end

  def create
    auth = Authentication.find_by_provider_and_uid 'email', params[:email]
    if auth && !params[:password].blank? && auth.user.authenticate(params[:password])
      if auth.state == 'active' # || auth.token_created_at > VERIFICATION_RESPITE.ago
        auto_login auth.user, remember_me: params[:remember_me]
        copy_return_to
        logged_in account_path, notice: t('sessions.flash.logged_in', user: auth.user.name)
      else
        @email = auth.uid
        if auth.user.authentications.emails.active.any?
          redirect_to unverified_emails_path, alert: t('sessions.flash.email_not_verified', email: auth.uid)
        else
          redirect_to activating_account_path, alert: t('sessions.flash.email_not_verified', email: auth.uid)
        end
      end
    else
      flash.now.alert = t('sessions.flash.invalid_login')
      render :new
    end
  end

  def destroy
    logout
    redirect_to root_url, notice: t('sessions.flash.logged_out')
  end

  def setup
    render nothing: true
  end

  def failure
    if params[:message]= 'invalid_credentials'
      redirect_to (current_user ? account_path : root_path),
                  alert: t('sessions.flash.oath_cancel')
    else
      redirect_to (current_user ? account_path : root_path),
                  alert: t('sessions.flash.oath_error', error: params[:message])
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
          redirect_to account_path, notice: "#{@auth["provider"].titleize} account #{@auth['info']['name']} already added."
        else
          redirect_to account_path, alert: "#{@auth["provider"].titleize} account #{@auth['info']['name']} belongs to user #{user.name}."
        end
        return
      end
      copy_return_to
      reset_session
      auto_login user
      logged_in account_path, notice: "Logged in as #{user.name} using #{@auth["provider"].titleize} account #{@auth['info']['name']}."
    end
  end

  def oauth_link_to_current_user
    user = current_user
    if user
      add_oauth user
      copy_return_to
      reset_session
      auto_login user
      logged_in account_path, notice: "Added login using #{@auth["provider"].titleize} account #{@auth['info']['name']}."
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
          logged_in account_path, notice: "Logged in as #{user.name} using #{@auth["provider"].titleize} account #{@auth['info']['name']}."
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
    a = OAuthAuthentication.new provider: @auth["provider"], uid: @auth["uid"]
    a.user = user
    a.save!
    a
  end

end
