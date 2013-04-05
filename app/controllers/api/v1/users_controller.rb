
    class Api::V1::UsersController < ApplicationController  
      skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
      before_filter :authenticate_user!
      def index
        @users = User.order('created_at desc')
      end
      
      def show
        find_user
        if !@user
           render :status => 404,
           :json => { :success => false,
                      :info => "Process Failed", 
                      :errors => "User doesn't exist"}
        
        end
      end
      
      
      private
      
      def find_user
        @user = User.find params[:id]
      end
      
    end    


