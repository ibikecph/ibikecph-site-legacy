class FollowsController < ApplicationController

  before_filter :require_user
  before_filter :find_followable

  def follow
    if current_user.follow @followable
      render :update
    else
      render :nothing => true
    end
  end
  
  def unfollow
    if current_user.unfollow @followable
      render :update
    else
      render :nothing => true
    end
  end
  
  private
  
  def require_user
    render :nothing => true unless current_user
  end
  
  def find_followable
    @followable = params[:followable_type].constantize.find params[:followable_id] rescue nil
  end

end
