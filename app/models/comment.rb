class Comment < ActiveRecord::Base

  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :user

  MAXLENGTH = { body: 2000 }

  validates :body, presence: true, length: { maximum: MAXLENGTH[:body] }

end
