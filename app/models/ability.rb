class Ability
  include CanCan::Ability

  def initialize(user)
    can [:index], [ReportedIssue, Favourite, Route]
    can [:show], [User, ReportedIssue, Favourite, Route]
    can :create, User

    if user
      if user.admin?
        can :manage, :all
      else
        can :create, [Favourite, Route, ReportedIssue]
        can :destroy, [Favourite, Route] do |t|
          t.user_id == user.id
        end
        if user.staff?
          can :manage, [ReportedIssue]
        end
        can [:update], [Favourite, Route] do |t|
          t.user_id == user.id
        end
        can [:reorder], Favourite do |t|
          t.user_id == user.id
        end

        can [:change_password,:add_password,:has_password], User do |t|
          t.id == user.id
        end
      end

      # cannot :delete, User
      can :destroy, User do |t|
        t.id == user.id
      end
    end
  end

end
