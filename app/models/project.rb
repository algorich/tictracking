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

  def filter(users: users, begin_at: begin_at, end_at: end_at)
    users_tasks = {}
    users.each { |u| users_tasks[u] = filter_tasks_by(u,begin_at,end_at) }
    users_tasks
  end

  # users_tasks = { user_1: [ task1, task2 ], ... }
  def time_worked_by_all(users_tasks)
    all_tasks = users_tasks.values.flatten
    all_tasks.reduce(0) { |total, task| total + task.time_worked }
  end

  private

  def filter_tasks_by(user, begin_at, end_at)
    tasks.joins(:worktimes).where(
      'worktimes.beginning >= :begin_at AND worktimes.finish <= :end_at AND worktimes.user_id = :user_id',
      {
        user_id: user.id,
        begin_at: begin_at,
        end_at: end_at
      }).distinct.includes(:worktimes)
  end
end
