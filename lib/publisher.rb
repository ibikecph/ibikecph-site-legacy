class Publisher
  
  include Rails.application.routes.url_helpers
  
  def self.publish object
    self.new.delay.publish object.class.name, object.id, (I18n.default_locale ? nil : I18n.locale) if object
  end
    
  def publish klass, id, locale
    return unless k=klass.constantize
    return unless object = k.find_by_id(id)
    case object
    when BlogEntry
      blog object, locale
    when Comment
      comment object, locale
    end
  end
  
  def blog blog_entry, locale
    User.where(:notify_by_email => true).each do |user|
      UserMailer.blog_entry(user,blog_entry,locale).deliver if user != blog_entry.user
    end
  end

  def comment comment, locale
    comment.commentable.followers.where(:notify_by_email => true).each do |user|
      UserMailer.comment(user,comment,locale).deliver if user != comment.user
    end
  end
  
end
