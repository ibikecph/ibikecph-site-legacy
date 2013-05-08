class Api::V1::BaseController < ApplicationController  
  
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }   
 
  rescue_from CanCan::AccessDenied do |exception|
         render :status => 401,
         :json => { :success => false,
                    :info => "Unauthorized access!", 
                  :errors => "Unauthorized access!"}
  end

 private

  def check_auth
    unless current_user
       render :status => 403,
       :json => { :success => false,
                  :info => "Login Failed",
                  :invalid_token=>true,
                  :errors => "Invalid authentication token."}
    end
  end   

end    


