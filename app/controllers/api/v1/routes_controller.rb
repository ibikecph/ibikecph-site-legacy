class Api::V1::RoutesController < Api::V1::BaseController 
  
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  before_filter :check_auth, :if => Proc.new { |c| c.request.format == 'application/json' }
  before_filter :manage_duplicate_routes, :only=>:create
  load_and_authorize_resource :user
      
  def index
    @routes=current_user.routes.recent_routes
  end
  
  def create    
        @route = current_user.routes.new params[:route]
        if @route.save          
           render :status => 201,
           :json => { :success => true,
                      :info => "Route created successfully!",
                      :data => { :id => @route.id } }
        else
           render :status => 422,
           :json => { :success => false,
                      :info => @route.errors.full_messages.first, 
                      :errors => @route.errors.full_messages}
        end
    
  end
  
  def show
     @route=current_user.routes.find_by_id(params[:id])
     if !@route
           render :status => 404,
           :json => { :success => false,
                      :info => "Route doesn't exist!", 
                      :errors => "Route doesn't exist!"}   
     end   
  end
  
  def update
    @route=current_user.routes.find_by_id(params[:id])
    if @route.update_attributes(params[:route])
           render :status => 200,
           :json => { :success => true,
                      :info => "Route updated successfully!",
                      :data => { :id => @route.id } }
    else
           render :status => 400,
           :json => { :success => false,
                      :info => @route.errors.full_messages.first, 
                      :errors => @route.errors.full_messages}  
    end
  end
  
  def destroy

    @route=current_user.routes.find_by_id(params[:id])
    if @route   
       @route.destroy
       render :status => 200,
       :json => { :success => true,
                  :info => "Route deleted successfully!",
                  :data => {} }  
    else
    render :status => 404,
     :json => { :success => false,
                :info => "Route doesn't exist!", 
                :errors => "Route doesn't exist!"}                 
    end           
  end
  
      private
           
      def manage_duplicate_routes
        @croute=current_user.routes.find_by_from_name_and_to_name(params[:route][:from_name],params[:route][:to_name])
        @croute.destroy if @croute
      end
      
end