class Ability
  include CanCan::Ability

  def initialize(user)
    can [:index], [Comment, Issue, ReportedIssue, Favourite, Route, Track]
    can [:show], [Comment, User, Issue, ReportedIssue, Favourite, Route]
    can [:index, :archive, :show, :tag, :feed], [BlogEntry]
    can :create, User

    if user
      if user.admin?
        can :manage, :all
      else
        can :create, [Favourite, Route, Comment, Issue, ReportedIssue, Vote, Track, Coordinate]
        can [:show,:destroy], Track
        can [:vote, :unvote], Issue
        can :destroy, [Follow, Favourite, Route] do |t|
          t.user_id == user.id
        end
        if user.staff?
          can :manage, [BlogEntry, Issue, ReportedIssue, Comment, Vote]
        end
        can [:update], [Favourite, Route, Track] do |t|
          t.user_id == user.id
        end
        can [:reorder], Favourite do |t|
          t.user_id == user.id
        end

        can :change_password, User do |t|
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
