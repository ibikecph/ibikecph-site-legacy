class Ability < ActiveRecord::Base
  include CanCan::Ability

  def initialize(user)
    disable_risky_blocks

    can [:index,:show], [Comment,User,Issue]
    can [:index,:archive,:show,:tag], [BlogEntry]
    can :create, User
    if user
      if user.role == "super"
        can :all, :all 
      else
        can :create, [Comment,Issue,Vote]
        can [:vote,:unvote], Issue
        can :destroy, [Follow] do |t|
          t.user.id == user.id
        end
    
      end
    end
  end
  
  
end
