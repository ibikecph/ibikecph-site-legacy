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
    when Theme
      theme object, locale
    when Comment
      comment object, locale
    end
  end
  
  def blog blog_entry, locale
    User.all.each do |user|
      if user.notify_by_email && user != blog_entry.user
        UserMailer.blog_entry(user,blog_entry,locale).deliver
      end
    end
  end

  def theme theme, locale
    User.all.each do |user|
      if user.notify_by_email && user != theme.user
        UserMailer.theme(user,theme,locale).deliver
      end
    end
  end

  def comment comment, locale
    comment.commentable.followers.each do |user|
      if user.notify_by_email && user != comment.user
        UserMailer.comment(user,comment,locale).deliver
      end
    end
  end
  
end
