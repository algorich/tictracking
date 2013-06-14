class Project < ActiveRecord::Base
  has_many :tasks
  has_many :memberships
  has_many :users, through: :memberships

  attr_accessible :name, :user_ids

  validates :name, :user_ids, presence: true

  def set_admin(user)
    self.memberships.create!(admin: true, user: user)
  end
end
