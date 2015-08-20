class Api::V1::BaseController < ApplicationController

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :check_format!
  before_filter :check_auth_token!

  rescue_from CanCan::AccessDenied do |exception|
    render status: 401,
           json: {
             success: false,
             info: t('api.flash.unauthorized'),
             errors: t('api.flash.unauthorized')
           }
  end

  private

  def check_auth_token!
    auth_token = params[:auth_token].presence
    user       = auth_token && User.find_by_authentication_token(auth_token.to_s)

    if user
      # Notice we are passing store false, so the user is not
      # actually stored in the session and a token is needed
      # for every request. If you want the token to work as a
      # sign in token, you can simply remove store: false.
      #sign_in user, store: false
      sign_in :user, user, store: false
    else
      render status: 403,
             json: {
               success: false,
               info: 'Login Failed',
               invalid_token: true,
               errors: t('api.flash.invalid_token')
             }
    end
  end

  def check_format!
    unless params[:format] == 'json'
      render nothing: true, status: 406
    end
  end

end
