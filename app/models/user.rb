class User < ActiveRecord::Base
  has_many :worktimes

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
   :trackable, :validatable, :confirmable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  has_many :tasks
  has_many :memberships
  has_many :projects, through: :memberships

  def admin?(project)
    memberships.where(project_id: project.id, admin: true).any?
  end

  def member?(project)
    memberships.where(project_id: project.id).any?
  end
end
