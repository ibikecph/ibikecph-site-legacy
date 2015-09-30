class Api::V1::BaseController < ApplicationController

  #skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :check_format!
  before_filter :check_auth_token!

  rescue_from CanCan::AccessDenied, :with => :unauthorized

  private

  def check_auth_token!
    auth_token   = verified_request? && cookies.signed[:auth_token].presence
    auth_token ||= params[:auth_token].presence
    user         = auth_token && User.find_by_authentication_token(auth_token.to_s)

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
    json_response 200,
                  true,
                  info,
                  data:options
  end

  def created(options={})
    json_response 201,
                  true,
                  controller_name.classify + ' ' + t('api.flash.created'),
                  data:options
  end

  def failure(resource)
    json_response 400,
                  false,
                  resource.errors.full_messages.first,
                  errors: resource.errors.full_messages
  end

  def unauthorized
    json_response 401,
                  false,
                  t('api.flash.unauthorized'),
                  errors: [t('api.flash.unauthorized')]
  end

  def record_not_found(resource_name=nil)
    json_response 404,
                  false,
                  controller_name.classify + ' ' + t('api.flash.not_found'),
                  errors: [controller_name.classify + ' ' + t('api.flash.not_found')]
  end

  def json_response(status, success, info, options={})
    render status: status,
           json: ({
               success: success,
               info: info,
           }).merge(options)
  end
end
