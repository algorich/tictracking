class Project < ActiveRecord::Base
  has_many :tasks, dependent: :destroy
  has_many :memberships
  has_many :users, through: :memberships

  validates :name, :memberships, presence: true

  def set_admin(user)
    membership = memberships.where(user_id: user.id).first
    if membership
      membership.update_attribute(:role, 'admin')
    else
      memberships.build(role: 'admin', user: user)
    end
  end

  def can_add?(user)
    self.errors[:user].clear

    if user.nil?
      self.errors[:user] = "User can't be blank!"
      return false

    elsif users.include?(user)
      self.errors[:user] = 'User already in this project'
      return false
    end

    return true
  end

  def get_all_time_worked(begin_at: begin_at, end_at: end_at)
    project_info = { users: {} }

    project_info[:time_worked_by_all] = users.reduce(0) do |total, user|
      project_info[:users][user] = user.time_worked_on(project: self, begin_at: begin_at, end_at: end_at)

      total += project_info[:users][user][:time_worked_at_all]
    end

    project_info
  end
end
