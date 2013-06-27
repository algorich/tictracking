class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  attr_accessible :admin, :project, :user

  def toggle_admin!
    if can_toggle_admin?
      self.admin = !self.admin
      self.save
    end
  end

  def can_toggle_admin?
    !(project.memberships.where(admin: true).size == 1 && self.admin?)
  end
end
