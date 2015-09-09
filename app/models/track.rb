class Track < ActiveRecord::Base
  before_validation       :set_salted_signature
  validates_uniqueness_of :salted_signature

  validates_presence_of   :signature,
                          :salted_signature,
                          :count,
                          :timestamp,
                          :to_name,
                          :from_name,
                          :coordinates

  attr_accessor :signature, :count, :coord_count

  serialize     :coordinates, JSON

  def time_at_point i
    Time.at(self.timestamp.to_i + self.coordinates[i]['seconds_passed'].to_i)
  end

  def self.find_all_by_signature(unsalted_signature, count)
    signatures = []

    (0..count).each do |i|
      signatures << Track.generate_signature(unsalted_signature, i)
    end

    Track.where('salted_signature IN (:signatures)', signatures: signatures)
  end

  def self.update_all_signatures(old_signature, new_signature, count)
    tracks = Track.find_all_by_signature(old_signature, count)

    tracks.each_with_index do |track,i|
      track.update_attributes!(signature: new_signature, count: i)
    end
  end

  def validate_ownership(signature, count)
    (0..count).each do |i|
     return true if self.salted_signature == Track.generate_signature(signature, i)
    end
    false
  end

  def save_and_update_count(user)
    self.count = user.track_count
    user.track_count += 1

    ActiveRecord::Base.transaction do
      user.save!
      self.save!
    end
  end

  def self.generate_signature(signature, count)
    BCrypt::Engine.hash_secret signature + count.to_s, ENV['BCRYPT_SALT']
  end

  def coordinates_created?
    (self.coordinates.count.to_s == self.coord_count.to_s) ? true : self.errors.add(:base, "Invalid number of coordinates created")
  end

  private
  def set_salted_signature
    self.salted_signature = Track.generate_signature self.signature, self.count
  end
end
