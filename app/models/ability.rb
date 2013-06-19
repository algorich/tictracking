class Ability
  include CanCan::Ability

  def initialize(user)
    #Project
    can [:manage, :change_admin, :team], Project do |p|
      user.admin? p
    end

    can :create, Project

    can :read, Project do |p|
      user.member? p
    end

    #Task
    can [:update, :destroy, :create, :read], Task do |t|
      user.member? t.project
    end

  end
end
