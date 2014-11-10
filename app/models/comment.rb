class Comment < ActiveRecord::Base

  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :user

  attr_accessible :title,
                  :body,
                  :commentable_id,
                  :commentable_type

  MAXLENGTH = { body: 2000 }

  validates :body, presence: true, length: { maximum: MAXLENGTH[:body] }

end
