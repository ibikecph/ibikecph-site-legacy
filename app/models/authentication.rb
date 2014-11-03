class Authentication < ActiveRecord::Base

  #belongs_to :user

  scope :emails, where(type: 'EmailAuthentication')
  scope :oauths, where(type: 'OAuthAuthentication')
  scope :active, where(state: 'active').order('created_at desc')
  scope :facebooks, where(type: 'OAuthAuthentication', provider: 'facebook')
  scope :unverified, where(state: 'unverified').order('created_at desc')

  attr_accessible :provider, :uid

  validates_presence_of :uid
  validates_uniqueness_of :uid

  before_create :activate

  def activate
    self.state = 'active'
    self.activated_at = Time.zone.now
    self.token = nil
  end

  def active?
    state == 'active'
  end

  def unverified?
    state == 'unverified'
  end

  def generate_token
    begin
      self.token = SecureRandom.urlsafe_base64
    end while Authentication.exists?(token: self.token)
    self.token_created_at = Time.zone.now
  end

  def name
    uid
  end

  #make Authentication.build type: 'SubClass' work
  #http://coderrr.wordpress.com/2008/04/22/building-the-right-class-with-sti-in-rails/
  class << self
    def new_with_cast(*a, &b)
      if (h = a.first).is_a? Hash and (type = h[:type] || h['type']) and (klass = type.constantize) != self
        h.delete :type
        raise "Cannot build, because requested type is not a descendant."  unless klass < self  # klass should be a descendant of us
        return klass.new(*a, &b)
      end

      new_without_cast(*a, &b)
    end
    alias_method_chain :new, :cast
  end
end
