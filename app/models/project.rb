class Project < ActiveRecord::Base
  has_many :tasks
  has_many :memberships
  has_many :users, through: :memberships

  attr_accessible :name, :user_ids

  validates :name, :users, presence: true

  def set_admin(user)
    self.memberships.build(admin: true, user: user)
  end
end
