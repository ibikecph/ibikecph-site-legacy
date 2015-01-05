class Api::V1::BaseController < ApplicationController

  skip_before_filter :verify_authenticity_token, if: Proc.new { |c| c.request.format == 'application/json' }

  rescue_from CanCan::AccessDenied do |exception|
    render status: 401,
           json: {
             success: false,
             info: t('api.flash.unauthorized'),
             errors: t('api.flash.unauthorized')
           }
  end

  private

  def check_auth
    unless current_user
      render status: 403,
             json: {
               success: false,
               info: 'Login Failed',
               invalid_token: true,
               errors: t('api.flash.invalid_token')
             }
    end
  end

end
