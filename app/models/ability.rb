class Ability < ActiveRecord::Base
  include CanCan::Ability

  def initialize(user)
    disable_risky_blocks

    can [:index,:show], [BlogEntry,Comment,User]
    if user
      if user.role == "super"
        can :manage, :all 
      else
        can :create, Comment
      end
    end
  end
  
  
end
