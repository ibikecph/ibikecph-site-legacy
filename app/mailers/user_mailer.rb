class UserMailer < ActionMailer::Base
  
  default from: "auto@#{MAIN_DOMAIN}"
  
  #we pass objects ids instead of objecst because we're using delayed_job to send email
  #that way only the id will be stored in the database, instead of the entire object (which could also be stale)
  
  def activation authentication_id
    verification authentication_id, t('user_mailer.activation.subject')
  end

  def verify_email authentication_id
    verification authentication_id, t('user_mailer.verify_email.subject')
  end
  
  def password_reset user_id
    @user = User.find user_id
    @url = reset_by_token_password_resets_url :token => @user.password_reset_token
    mail :to => @user.email_address, :subject => t('user_mailer.password_reset.subject')
  end
  
  private

  def verification authentication_id, subject
    auth = EmailAuthentication.find authentication_id
    @user = auth.user
    @url = verify_by_token_emails_url auth.token
    mail :to => auth.uid, :subject => subject
  end
  
end
