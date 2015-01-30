class Ability
  include CanCan::Ability

  def initialize(user)

    can [:index], [Comment, Issue, ReportedIssue, Favourite, Route]
    can [:show], [Comment, User, Issue, ReportedIssue, Favourite, Route]
    can [:index, :archive, :show, :tag, :feed], [BlogEntry]
    can :create, User

    if user
      if user.role == 'super'
        can :manage, :all
      else
        can :create, [Favourite, Route, Comment, Issue, ReportedIssue, Vote]
        can [:vote, :unvote], Issue
        can :destroy, [Follow, Favourite, Route] do |t|
          t.user.id == user.id
        end
        if user.role == 'staff'
          can :manage, [BlogEntry, Issue, Comment, Vote]
          can :manage, [BlogEntry, Issue, ReportedIssue, Comment, Vote]
        end
        can [:update, :create], [Favourite, Route] do |t|
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

    # cannot :delete, User
  end

end
