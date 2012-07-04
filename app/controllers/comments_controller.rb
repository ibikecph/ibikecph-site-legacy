class CommentsController < ApplicationController
  
  load_and_authorize_resource

  def create
    if current_user
      @comment = Comment.new params[:comment]
      @comment.commentable_type = params[:commentable_type]
      @comment.commentable_id = params[:commentable_id]
      @comment.user_id = current_user.id
      if @comment.save
        Publisher.publish @comment
      else
        render :error
      end
    else
      render :nothing => true
    end
  end
  
  def destroy
    @comment.destroy
  end

  private
  
  def find_comment
    @comment = Comment.find params[:id]
  end
  
  def authorize_create
    authorize! :create, Comment
  end

  def authorize_manage
    authorize! :manage, @comment
  end
  
end
