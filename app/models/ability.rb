class Ability < ActiveRecord::Base
  include CanCan::Ability

  def initialize(user)
    disable_risky_blocks

    can [:index,:show], [Comment,User,Issue,Favourite]
    can [:index,:archive,:show,:tag], [BlogEntry]
    can [:index,:show], [Theme]
    can :create, User
    if user
      if user.role == 'super'
        can :manage, :all
      else
        can :create, [Comment,Issue,Vote]
        can [:vote,:unvote], Issue
        can :destroy, [Follow,Favourite] do |t|
          t.user.id == user.id
        end 
        can [:update,:create], Favourite do |t|
          t.user.id == user.id
        end 
      end
    end
    cannot :delete, User 
  end
  
end
