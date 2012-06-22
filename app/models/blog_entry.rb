class BlogEntry < ActiveRecord::Base
  
  belongs_to :user
  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'
  scope :latest, order('sticky desc, created_at desc')
  mount_uploader :image, ResizedImageUploader
  attr_accessible :title, :body, :image, :remove_image, :image_cache, :sticky
  MAXLENGTH = { :title => 100, :body => 5000 }
  
  validates :title, :presence => true, :uniqueness => true, :length => { :maximum => MAXLENGTH[:title] }
  validates :body, :presence => true, :length => { :maximum => MAXLENGTH[:body] }
  
  def global?
    bloggable_id == nil
  end
end
