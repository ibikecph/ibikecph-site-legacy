class Theme < ActiveRecord::Base
  belongs_to :user
  has_many :themings, :dependent => :destroy
  has_many :issues, :through => :themings
    
  scope :latest, order('sticky desc, created_at desc')
  mount_uploader :image, ResizedImageUploader
  attr_accessible :title, :body, :image, :remove_image, :image_cache, :sticky
  
  MAXLENGTH = { :title => 100, :body => 5000 }

  validates :title, :presence => true, :uniqueness => true, :length => { :maximum => MAXLENGTH[:title] }
  validates :body, :presence => true, :length => { :maximum => MAXLENGTH[:body] }
end
