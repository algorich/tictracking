class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
   :trackable, :validatable, :confirmable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  has_many :worktimes
  has_many :tasks, through: :worktimes, uniq: true
  has_many :memberships
  has_many :projects, through: :memberships

  def admin?(project)
    memberships.where(project_id: project.id, admin: true).any?
  end

  def member?(project)
    memberships.where(project_id: project.id).any?
  end

  def latest_tasks(n=1)
    tasks.order('updated_at DESC').first(n)
  end
end
