class Membership < ActiveRecord::Base
  ROLES = %w[admin observer common_user]

  belongs_to :user
  belongs_to :project

  #TODO: adicionar :admin e comentar role para fazer o deploy
  attr_accessible :project, :user, :role
  validates :role, presence: true

  def toggle_admin!
    if can_toggle_admin?
      self.role = self.admin? ? 'common_user' : 'admin'
      self.save
    end
  end

  def can_toggle_admin?
    !(project.memberships.where(role: 'admin').size == 1 && self.admin?)
  end

  def admin?
    self.role == 'admin'
  end
end
