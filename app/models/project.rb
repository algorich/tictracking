class Project < ActiveRecord::Base
  has_many :tasks, dependent: :destroy
  has_many :memberships
  has_many :users, through: :memberships

  attr_accessible :name, :user_ids
  attr_reader :tasks_times_array

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

  def time_worked(user: user, begin_at: begin_at, end_at: end_at)
    set_tasks_times(user, begin_at, end_at).reduce(0) { |total, hash| total += hash[:time] }
  end

  private

  def set_tasks_times(user, begin_at, end_at)
    @tasks_times_array = []
    self.tasks.each do |task|
      worktimes = Worktime.find_by_time(user: user, begin_at: begin_at, end_at: end_at, task: task)
      if worktimes.present?
        @tasks_times_array << {
          id: task.id,
          name: task.name,
          time: worktimes.reduce(0) { |total,worktime| total += worktime.time_worked}
        }
      end
    end
    @tasks_times_array
  end
end
