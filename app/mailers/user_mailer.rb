class UserMailer < ActionMailer::Base
  
  include ActionView::Helpers::TextHelper

  default from: "auto@#{MAIN_DOMAIN}"

  #we pass objects ids instead of objecst because we're using delayed_job to send email
  #that way only the id will be stored in the database, instead of the entire object (which could also be stale)
  
  def activation authentication_id, locale
    verification authentication_id, t('user_mailer.activation.subject'), locale
  end

  def verify_email authentication_id, locale
    verification authentication_id, t('user_mailer.verify_email.subject'), locale
  end
  
  def password_reset user_id, locale
    @user = User.find user_id
    @url = url_for :controller => :password_resets, :action => :edit, :token => @user.password_reset_token, :locale => locale
    mail :to => @user.email_address, :subject => t('user_mailer.password_reset.subject')
  end
  
  def blog_entry user, blog_entry, locale
    @user = user
    @blog_entry = blog_entry
    @url = url_for :controller => :blog, :action => :show, :id => blog_entry.id,  :locale => locale
    @settings_url = settings_url locale
    mail :to => @user.email_address, :subject => t('user_mailer.blog_entry.subject', :title => blog_entry.title)
  end

  def comment user, comment, locale
    @user = user
    @comment = comment
    @author = comment.user
    @target = comment.commentable
    @title = truncate(@comment.body, :length => 40, :separator => ' ', :omission => '...')
    case @target
    when BlogEntry
      @url = url_for :controller => :blog, :action => :show, :id => @target.id, :locale => locale
    when Issue
      @url = url_for :controller => :issues, :action => :show, :id => @target.id, :locale => locale
    else
      return
    end
    @settings_url = settings_url locale
    mail :to => @user.email_address, :subject => t('user_mailer.comment.subject', :title => @title)
  end
  
  private

  def verification authentication_id, subject, locale
    auth = EmailAuthentication.find authentication_id
    @user = auth.user
    @url = url_for :controller => :emails, :action => :verify, :token => auth.token, :locale => locale
    mail :to => auth.uid, :subject => subject
  end
  
  
  def settings_url locale
    url_for :controller => :accounts, :action => :settings, :locale => locale
  end
  
end
