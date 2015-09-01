class PrivacyToken < ActiveRecord::Base
  validates_uniqueness_of :signature

  def self.generate_signature(username, password)
    BCrypt::Password.new(username+password)
  end
end
