class Vote < ActiveRecord::Base

  belongs_to :issue, counter_cache: true
  belongs_to :user

  attr_accessible

  def self.has_voted? user, idea
    return nil unless user && idea

    Vote.exists? user_id: user.id, idea_id: idea.id
  end

  def self.vote_up user, idea
    return false unless user && idea
    return false if self.has_voted? user, idea

    vote = Vote.new
    vote.idea = idea
    vote.user = user
    vote.save!

    true
  end

  def self.vote_down user, idea
    return false unless user && idea

    vote = self.find_vote user, idea

    if vote
      vote.destroy
      return true
    end

    false
  end

end
