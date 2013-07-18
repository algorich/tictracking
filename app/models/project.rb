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

  def time_worked(user)
    tasks_times(user).reduce(0) { |total, array| total += array[1] }
  end

  def tasks_times(user)
    hash = {}
    self.tasks.each do |task|
      worktimes = task.worktimes.where(user_id: user.id)
      if worktimes.present?
        hash[task.name] = worktimes.reduce(0) { |total,worktime| total += worktime.time_worked}
      end
    end
    @tasks_times_array = hash
  end
end
