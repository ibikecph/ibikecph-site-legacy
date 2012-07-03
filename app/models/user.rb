class User < ActiveRecord::Base
  
  has_many :authentications, :dependent => :destroy
  has_many :blog_entries, :dependent => :nullify
  has_many :comments, :dependent => :destroy
  attr_accessible :role, :name, :about, :password, :password_confirmation, :image, :remove_image, :image_cache, :notify_by_email, :terms
  
  attr_accessor :password, :created_from_oath
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :password, :on => :create, :unless => :has_oath_authentications
  validates_length_of :password, :minimum => 3, :if => :password
  validates_confirmation_of :password, :if => :password
  validates_acceptance_of :terms
  
  accepts_nested_attributes_for :authentications
  
  mount_uploader :image, SquareImageUploader

  MAXLENGTH = { :name => 50, :about => 2000 }
  
  before_save :encrypt_password
  

  
  def facebook_auth
    authentications.facebooks.active.first
  end
  
  def has_oath_authentications
    @created_from_oath || authentications.where(:type=>'OAuthAuthentication').any?
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
    UserMailer.delay.password_reset(id)
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
  
  def email
    authentications.emails.active.first
  end
  
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
  
end
