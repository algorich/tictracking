class Ability
  include CanCan::Ability

  def initialize(user)
    can [:manage, :change_admin, :team], Project do |p|
      user.admin? p
    end

    can :create, Project

    can :read, Project do |p|
      user.member? p
    end
  end
end
