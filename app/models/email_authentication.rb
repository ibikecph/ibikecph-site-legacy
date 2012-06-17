class EmailAuthentication < Authentication
  
  validates_uniqueness_of :uid, :case_sensitive => false
  validates_format_of :uid, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i, :message => "must be a valid address", :allow_blank => true
  attr_accessible :uid_confirmation
  validates_presence_of :uid_confirmation, :on => :create
  validates_confirmation_of :uid, :message => "should match confirmation"
  
  before_create do
    self.provider = 'email'
    self.state = 'unverified'
  end
  
  def send_activation
    generate_token
    save!
    UserMailer.delay.activation(id)
  end

  def send_verify
    generate_token
    save!
    UserMailer.delay.verify_email(id)
  end
  
end