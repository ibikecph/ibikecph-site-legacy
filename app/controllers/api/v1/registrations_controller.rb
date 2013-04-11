
    class Api::V1::RegistrationsController < Devise::RegistrationsController  
      skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }           
      
      def new
        @user = User.new
      end
    
      def create
        params[:user].delete(:role)     #never allow new users with a role    
        #handle images                       
        if params[:user][:image_path] && params[:user][:image_path]["file"]
          prepare_image_data(params[:user][:image_path])
        end
        @user = User.new params[:user]
        if @user.save
          #auto_login @user
          #logged_in account_path, :notice => "Account created. Welcome!"
          @user.reset_authentication_token!
            render :status => 201,
           :json => { :success => true,
                      :info => "Account created. Welcome!",
                      :data => { :auth_token => @user.authentication_token, :id=>@user.id } }
        else
           render :status => 422,
           :json => { :success => false,
                      :info => "Process Failed", 
                      :errors => @user.errors.messages}

        end
      end
      
      def update        
        @user=User.find_by_id(params[:id])
        if params[:user][:image_path] && params[:user][:image_path]["file"]
          prepare_image_data(params[:user][:image_path])
        end
        if @user.update_attributes(params[:user])
               render :status => 200,
               :json => { :success => true,
                          :info => "User details updated successfully!",
                          :data => { :id => @user.id } }
        else
               render :status => 400,
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
            
      def find_user
        @user = User.find params[:id]
      end
      
      def prepare_image_data(image_path_params)     
        tempfile = Tempfile.new("fileupload")
        tempfile.binmode
        tempfile.write(Base64.decode64(image_path_params["file"]))     
        uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => image_path_params["filename"], :original_filename => image_path_params["original_filename"]) 
        params[:user][:image] =  uploaded_file
        tempfile.delete
      end
      
    end    

