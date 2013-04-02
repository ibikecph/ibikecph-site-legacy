class Api::V1::SessionsController < Devise::SessionsController   
      
      skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
      prepend_before_filter :require_no_authentication, :only => [:create ]
      #include Devise::Controllers::InternalHelpers


  def create
   # warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
   if current_user
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged in",
                      :data => { :auth_token => current_user.authentication_token } }
   else
     failure
   end
  end

  def destroy
    #warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    #current_user.update_column(:authentication_token, nil)
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged out",
                      :data => {} }
  end

  def failure
    render :status => 401,
           :json => { :success => false,
                      :info => "Login Failed",
                      :data => {} }
  end
end
