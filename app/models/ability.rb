class Ability < ActiveRecord::Base
  include CanCan::Ability

  def initialize(user)
    disable_risky_blocks

    can [:index,:show], :all

    if user      
      if false  #
        #super user
        can :manage, :all 
      else
        #ordinary user
      end
    end  
  end
end
