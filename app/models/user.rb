class User < ActiveRecord::Base
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :token_authenticatable, :omniauthable, :omniauth_providers => [:facebook]
         
  #has_many :authentications, :dependent => :destroy
  has_many :blog_entries, :dependent => :nullify
  has_many :themes, :dependent => :nullify
  has_many :comments, :dependent => :destroy
  has_many :issues, :dependent => :destroy
  has_many :reported_issues, :dependent => :destroy
  has_many :favourites, :dependent => :destroy
  has_many :routes, :dependent => :destroy
  attr_accessible :name, :about,:email, :email_confirmation, :password, :password_confirmation, :image, :image_path, :remove_image, :image_cache, :notify_by_email, :terms, :tester, :provider, :uid
  attr_accessor :image_path
  #attr_accessor :password, :created_from_oath
  
  validates_presence_of :name
  #validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :password, :on => :create, :unless => :has_oath_authentications
  validates_length_of :password, :minimum => 3, :if => :password
  validates :password_confirmation, :presence => true, :if => :password, :unless => :has_oath_authentications
  validates_confirmation_of :password, :if => :password, :unless => :has_oath_authentications
  
  validates_acceptance_of :terms
  
  validates_uniqueness_of :email, :case_sensitive => false
  validates_format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i, :message => I18n.t('not_a_valid_email'), :allow_blank => true
  attr_accessible :email_confirmation
  validates_presence_of :email_confirmation, :on => :create
  validates_confirmation_of :email
  
  #accepts_nested_attributes_for :authentications
  
  mount_uploader :image, SquareImageUploader

  MAXLENGTH = { :name => 50, :about => 2000 }
  
  #before_save :encrypt_password
  

  
  def facebook_auth
    authentications.facebooks.active.first
  end
  
  def has_oath_authentications
    @created_from_oath || self.provider=='facebook'
  end
    
  def has_password?
    self.password_hash.blank? == false
  end
  
  def has_active_email?
    authentications.emails.active.any?
  end

  def has_unverified_email?
    authentications.emails.unverified.any?
  end
  
  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.delay.password_reset(id, (I18n.locale == I18n.default_locale ? nil : I18n.locale) )
  end

  def generate_token column
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
  
  def clear_token column
    self[column] = nil
  end
  
  def authenticate password
    if password_hash && password_salt
      password_hash == BCrypt::Engine.hash_secret(password,password_salt)
    else
      false
    end
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
    
  def add_email address, state=:unverified
    email = EmailAuthentication.new :provider => 'email', :uid => address
    email.user = self
    if email.save
      email.activate if state.to_s == 'active'
      return email.save
    end
    false
  end
    
  def emails
    authentications.emails
  end
  
  #def email
  #  authentications.emails.active.first
  #end
  
  def email_address
    authentications.emails.active.first.uid rescue nil
  end

  def find_follow target
    if target
      Follow.first :conditions => { 
          :user_id => self.id, 
          :followable_type => target.class.name, 
          :followable_id => target.id
        }
    end
  end

  def following? target
    target && Follow.exists?( :user_id => self.id, :followable_type => target.class.name,:followable_id => target.id, :active => true )
  end
  
  def follow target, options = {}
    update_follow target, true, options
  end

  def unfollow target, options={}
    update_follow target, false, options
  end
  
  def update_follow target, active, options={}
    follow = find_follow target
    if follow
      follow.update_attribute :active, active unless options[:unless_set]==true
    else
      follow = Follow.new
      follow.followable = target
      follow.user = self
      follow.active = active
      follow.save
    end
  end
  
  def tester?
    tester == true
  end
  
def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
  user = User.where(:email => auth.info.email).first
  unless user
    user = User.new(:name=>auth.extra.raw_info.name,
                         :provider=>auth.provider,
                         :uid=>auth.uid,
                         :email=>auth.info.email,
                         :email_confirmation=>auth.info.email
                         )
   user.reset_authentication_token!
  end
  return user
end
  
end
