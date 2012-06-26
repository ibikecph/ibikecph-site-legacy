class Ability < ActiveRecord::Base
  include CanCan::Ability

  def initialize(user)
    disable_risky_blocks

    can [:index,:show], [Comment,User,Issue]
    can [:index,:archive,:show], [BlogEntry]
    if user
      if user.role == "super"
        can :manage, :all 
      else
        can :create, [Comment,Issue,Vote]
        can :manage, [Follow,Vote] do |t|
          t.user.id == user.id
        end
    
      end
    end
  end
  
  
end
