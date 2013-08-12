class Project < ActiveRecord::Base
  has_many :tasks, dependent: :destroy
  has_many :memberships
  has_many :users, through: :memberships

  attr_accessible :name, :user_ids

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
    !users.include? user
  end

  def get_all_time_worked(begin_at: begin_at, end_at: end_at)
    project_info = { users: {} }

    project_info[:time_worked_by_all] = users.reduce(0) do |total, user|
      project_info[:users][user] = set_time_worked_by_user(user: user, begin_at: begin_at, end_at: end_at)

      total += project_info[:users][user][:time_worked_at_all]
    end

    project_info
  end

  private

  def set_time_worked_by_user(user: user, begin_at: begin_at, end_at: end_at)
    tasks_by_user = {}
    tasks_by_user[:tasks] = set_tasks_times_by_user(user, begin_at, end_at)

    tasks_by_user[:time_worked_at_all] = tasks_by_user[:tasks].reduce(0) do |total, task|
      total += task[:time] if task.present?
    end

    tasks_by_user
  end

  def set_tasks_times_by_user(user, begin_at, end_at)
    tasks_by_user = []

    self.tasks.each do |task|
      worktimes = Worktime.find_by_time(user: user, begin_at: begin_at, end_at: end_at, task: task)
      if worktimes.present?
        tasks_by_user << {
          id: task.id,
          name: task.name,
          time: worktimes.reduce(0) { |total,worktime| total += worktime.time_worked}
        }
      end
    end
    tasks_by_user
  end
end
