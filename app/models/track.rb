class Track < ActiveRecord::Base
  before_validation       :set_signature
  validates_uniqueness_of :signature

  validates_presence_of   :signature,
                          :unsalted_signature,
                          :count,
                          :timestamp,
                          :to_name,
                          :from_name,
                          :coordinates

  attr_accessor :unsalted_signature, :count

  belongs_to    :privacy_token

  serialize     :coordinates, JSON

  def time_at_point i
    Time.at(self.timestamp.to_i + self.coordinates[i]['seconds_passed'].to_i)
  end

  def self.find_all_by_signature(unsalted_signature, count)
    relation = Track.none

    (0..count).each do |i|
      signature = PrivacyToken.generate_signature unsalted_signature, i

      track = Track.find_by_signature signature

      relation.insert track if track
    end

    relation
  end

  private
  def set_signature
    self.signature = generate_signature self.unsalted_signature, self.count
  end

  def self.generate_signature(unsalted_signature, count)
    BCrypt::Engine.hash_secret unsalted_signature + count, ENV['BCRYPT_SALT']
  end
end
