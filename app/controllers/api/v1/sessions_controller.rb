class Api::V1::SessionsController < Devise::SessionsController   
      
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  
  prepend_before_filter :check_login_params, :only => [:create ]
  prepend_before_filter :require_no_authentication, :only => [:create ]
  
  def create
   Rails.logger.info("USER PARAMS ::::::: #{params.inspect}")
   if params[:user][:fb_token]
      fb = OmniAuth::Strategies::Facebook.new(ENV['IBIKECPH_FBAPP_ID'], ENV['IBIKECPH_FBAPP_SECRET']) 
      client = ::OAuth2::Client.new(ENV['IBIKECPH_FBAPP_ID'], ENV['IBIKECPH_FBAPP_SECRET'], fb.options.client_options) 
      access_token = ::OAuth2::AccessToken.new(client, params[:user][:fb_token])  
      fb.instance_variable_set("@access_token", access_token)
      @fbauth_hash=fb.auth_hash rescue nil    
      return failure unless @fbauth_hash 
        if @fbauth_hash 
          @user = User.find_for_facebook_oauth(@fbauth_hash, current_user)
          return failure unless @user 
            if @user
              sign_in(:user, @user)
              success @user
            end
        end  
   else
        build_resource
        resource = User.find_for_database_authentication(:email => params[:user][:email])        
        return failure unless resource

        if resource.valid_password?(params[:user][:password])
          resource.ensure_authentication_token!  
          success resource
        else
          failure
        end           
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

  private 

  def success logged_user    
      Rails.logger.info("CURRENT USER ::::::: SUCCESS > LU >>> #{logged_user.inspect} CU >>>> #{current_user.inspect}")
      current_user=logged_user
      render :status => 200,
             :json => { :success => true,
                        :info => "Logged in",
                        :data => { :auth_token => logged_user.authentication_token, :id=>logged_user.id } }
  end
  
  def failure
    render :status => 401,
           :json => { :success => false,
                      :info => "Login Failed",
                      :errors => "Login Failed"}
  end
  
  def check_login_params    
    if params[:user].blank? || (params[:user][:fb_token].blank? && params[:user][:email].blank? && params[:user][:password].blank?)
          render :status => 406,
                 :json => { :success => false,
                 :info => "Login Failed",
                 :errors => "Required parameter(s) missing."}
    end
  end
  
end
