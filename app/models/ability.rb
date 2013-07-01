class Ability
  include CanCan::Ability

  def initialize(user)
    #Project
    can [:manage, :change_admin, :team, :add_admin], Project do |p|
      user.admin? p
    end

    can :create, Project

    can [:read, :team], Project do |p|
      user.member? p
    end

    #Task
    can [:manage], Task do |t|
      user.member? t.project
    end

    #Worktime
    can [:manage], Worktime do |w|
      user.member? w.task.project
    end
  end
end
