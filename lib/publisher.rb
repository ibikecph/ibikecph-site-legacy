class Publisher
  
  include Rails.application.routes.url_helpers
  
  def self.publish object
    self.new.delay.publish object.class.name, object.id if object
  end
    
  def publish klass,id
    return unless k=klass.constantize
    return unless object = k.find_by_id(id)
    case object
    when BlogEntry
      blog object
    when Comment
      comment object
    end
  end
  
  def blog blog_entry
    User.all.each do |user|
      if user.notify_by_email
        UserMailer.blog_entry(user,blog_entry).deliver
      end
    end
  end

  def comment comment
    comment.commentable.followers.each do |user|
      if user.notify_by_email
        UserMailer.comment(user,comment).deliver
      end
    end
  end
  
end
