class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
   :trackable, :validatable, :confirmable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  has_many :tasks
  has_many :memberships
  has_many :projects, through: :memberships

  def admin?(project)
    memberships.where(project_id: project.id, admin: true).any?
  end
end
