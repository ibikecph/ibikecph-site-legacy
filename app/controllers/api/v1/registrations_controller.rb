
    class Api::V1::RegistrationsController < Devise::RegistrationsController  
      skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
      def index
        @users = User.order('created_at desc').paginate :page => params[:page], :per_page => 100
      end
      
      def show
      end
      
      def new
        @user = User.new
      end
    
      def create
        params[:user].delete(:role)     #never allow new users with a role
        @user = User.new params[:user]
        if @user.save
          #auto_login @user
          #logged_in account_path, :notice => "Account created. Welcome!"
          @user.reset_authentication_token!
            render :status => 201,
           :json => { :success => true,
                      :info => "Account created. Welcome!",
                      :data => { :auth_token => @user.authentication_token } }
        else
           render :status => 422,
           :json => { :success => false,
                      :info => "Process Failed", 
                      :errors => @user.errors.messages}

        end
      end
      
      private
        
      def warn_about_existing_name
        user = User.find_by_name @user.name
        if user
          @name = @auth['info']['name']
          render :existing_name
        end
      end
      
      private
      
      def find_user
        @user = User.find params[:id]
      end
      
    end    


