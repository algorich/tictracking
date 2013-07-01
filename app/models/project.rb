class Project < ActiveRecord::Base
  has_many :tasks, dependent: :destroy
  has_many :memberships
  has_many :users, through: :memberships

  attr_accessible :name, :user_ids

  validates :name, :memberships, presence: true

  def set_admin(user)
    membership = memberships.where(user_id: user.id).first
    if membership
      membership.update_attribute(:admin, true)
    else
      memberships.build(admin: true, user: user)
    end
  end

  def can_add?(user)
    !users.include? user
  end
end
