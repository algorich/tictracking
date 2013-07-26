class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
   :trackable, :validatable, :confirmable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  has_many :worktimes
  has_many :tasks, through: :worktimes, uniq: true
  has_many :memberships
  has_many :projects, through: :memberships

  def admin?(project)
    memberships.where(project_id: project, admin: true).any?
  end

  def member?(project)
    memberships.where(project_id: project).any?
  end

  def latest(n=1, stuffs)
    self.send(stuffs).order('updated_at DESC').first(n)
  end

  def exists_pending_worktimes?(task)
    Worktime.where(user_id: self, task_id: task, finish: nil).any?
  end
end
