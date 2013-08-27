class Membership < ActiveRecord::Base
  ROLES = %w[admin observer common_user]

  belongs_to :user
  belongs_to :project

  validates :role, presence: true

  def set_role!(role)
    return nil if role != 'admin' and !can_remove_admin?
    self.role = role
    self.save
  end

  def can_remove_admin?
    !(project.memberships.where(role: 'admin').size == 1 && self.admin?)
  end

  def admin?
    self.role == 'admin'
  end

  def observer?
    self.role == 'observer'
  end
end
