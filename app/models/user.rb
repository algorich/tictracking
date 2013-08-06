class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
   :trackable, :validatable, :confirmable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  has_many :worktimes
  has_many :tasks, through: :worktimes, uniq: true
  has_many :memberships
  has_many :projects, through: :memberships

  def membership(project)
    memberships.find_by_project_id(project.id)
  end

  def admin?(project)
    membership(project).try(:admin?)
  end

  def member?(project)
    membership(project).present?
  end

  def observer?(project)
    membership(project).try(:observer?)
  end

  def role_in?(project)
    membership(project).try(:role)
  end

  def latest(n=1, stuffs)
    self.send(stuffs).order('updated_at DESC').first(n)
  end

  def exists_pending_worktimes?(task)
    Worktime.where(user_id: self, task_id: task, finish: nil).any?
  end
end
