class Api::V1::BaseController < ApplicationController

  #skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :check_format!
  before_filter :check_auth_token!

  # something, somewhere, somehow is causing find_by_id to
  # raise an exception when it shouldn't. Therefore:
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  rescue_from CanCan::AccessDenied do |exception|
    unauthorized
  end

  private

  def check_auth_token!
    auth_token = cookies.permanent.signed[:auth_token].presence || params[:auth_token].presence
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

  def success(info=nil, options={})
    json_response 200, true, info, data:options
  end

  def failure(resource)
    json_response 400, false, nil, errors: resource.errors.full_messages
  end

  def unauthorized
    json_response 401, false, t('api.flash.unauthorized'), errors: t('api.flash.unauthorized')
  end

  def record_not_found(resource_name=nil)
    json_response 404, false, resource_name.to_s + ' ' + t('api.flash.not_found'), errors: resource_name.to_s + ' ' + t('api.flash.not_found')
  end

  def json_response(status, success, info, options={})
    render status: status,
           json: ({
               success: success,
               info: info,
           }).merge(options)
  end
end
