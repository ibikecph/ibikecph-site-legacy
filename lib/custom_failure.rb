class CustomFailure < Devise::FailureApp

  def respond
    if request.format == 'json'
      json_failure
    else
      super
    end
  end

  def json_failure
    self.status = 401
    self.content_type = 'json'
    self.response_body = {
      success: false,
      info_title: I18n.t('sessions.flash.confirm_account_title'),
      info: I18n.t('sessions.flash.confirm_account'),
      errors: I18n.t('sessions.flash.confirm_account')
    }.to_json
  end

end
