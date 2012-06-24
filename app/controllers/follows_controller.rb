class FollowsController < ApplicationController

  before_filter :require_login
  before_filter :find_followable
  before_filter :find_follow
  
  #before_filter :authorize_create, :only => [:create]
  #before_filter :authorize_manage, :except => [:create]

  def follow
    if current_user
      if @follow
        if @follow.update_attribute :active, true
          render :update
          return
        end
      else
        @follow = Follow.new
        @follow.followable = @followable
        @follow.user = current_user
        if @follow.save
          render :update
          return
        end
      end
    end
    render :nothing => true
  end

  def unfollow
    if @follow && @follow.update_attribute(:active, false)
      render :update
    else
      render :nothing => true
    end
  end
  
  private
  
  def find_followable
    @followable = params[:followable_type].constantize.find params[:followable_id] rescue nil
  end
  
  def find_follow
    @follow = Follow.find_by_user_id_and_followable_type_and_followable_id current_user.id, params[:followable_type], params[:followable_id]
  end
  
  def authorize_create
    authorize! :create, Follow
  end

  def authorize_manage
    authorize! :create, @follow
  end
  

end
