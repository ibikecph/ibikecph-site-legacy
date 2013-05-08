class Api::V1::SessionsController < Devise::SessionsController   
      
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  prepend_before_filter :require_no_authentication, :only => [:create ]

  def create
   # warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
   if params[:user][:fb_token]
      fb = OmniAuth::Strategies::Facebook.new(ENV['IBIKECPH_FBAPP_ID'], ENV['IBIKECPH_FBAPP_SECRET']) 
      client = ::OAuth2::Client.new(ENV['IBIKECPH_FBAPP_ID'], ENV['IBIKECPH_FBAPP_SECRET'], fb.options.client_options) 
      access_token = ::OAuth2::AccessToken.new(client, params[:user][:fb_token])  
      fb.instance_variable_set("@access_token", access_token)
      @fbauth_hash=fb.auth_hash rescue nil     
        if @fbauth_hash 
          @user = User.find_for_facebook_oauth(@fbauth_hash, current_user)
          if @user
            sign_in(:user, @user)
          end
        end     
   end
   
   if current_user
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged in",
                      :data => { :auth_token => current_user.authentication_token, :id=>current_user.id } }
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
                      :errors => "Login Failed"}
  end
  
end
