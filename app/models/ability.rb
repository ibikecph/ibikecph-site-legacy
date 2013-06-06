class Ability < ActiveRecord::Base
  include CanCan::Ability

  def initialize(user)
    disable_risky_blocks

    can [:index,:show], [Comment, User, Issue, Favourite, Route]
    can [:index,:archive,:show,:tag], [BlogEntry]
    can [:index,:show], [Theme]
    can :create, User
    if user
      if user.role == 'super'
        can :manage, :all
      else
        can :create, [Comment, Issue, Vote]
        can [:vote,:unvote], Issue
        can :destroy, [Follow, Favourite, Route] do |t|
          t.user.id == user.id
        end 
        can [:update,:create], [Favourite, Route] do |t|
          t.user.id == user.id
        end
        can [:reorder], Favourite do |t|
          t.user.id == user.id
        end  
      end
    end
      can :destroy, User do |t|
        t.id == user.id
      end 
    #cannot :delete, User 
  end
  
end
