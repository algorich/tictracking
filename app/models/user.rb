class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
   :trackable, :validatable, :confirmable

  has_many :worktimes
  has_many :tasks, -> { uniq }, through: :worktimes
  has_many :memberships
  has_many :projects, through: :memberships

  def membership(project)
    memberships.find_by_project_id(project.id)
  end

  def admin?(project)
    membership(project).try(:admin?)
  end

  def member?(project)
    membership(project).present?
  end

  def observer?(project)
    membership(project).try(:observer?)
  end

  def role_in?(project)
    membership(project).try(:role)
  end

  def latest(n=1, stuffs)
    self.send(stuffs).order('updated_at DESC').first(n)
  end

  def exists_pending_worktimes?(task)
    Worktime.where(user_id: self, task_id: task, finish: nil).any?
  end

  def time_worked_on(project: project, begin_at: begin_at, end_at: end_at)
    tasks_and_time = {}
    tasks_and_time[:tasks] = get_tasks_time_worked(project, begin_at, end_at)

    tasks_and_time[:time_worked_at_all] = tasks_and_time[:tasks].reduce(0) do |total, task|
      total += task[:time] if task.present?
    end

    tasks_and_time
  end

  private

  def get_tasks_time_worked(project, begin_at, end_at)
    tasks = []

    project.tasks.each do |task|
      worktimes = Worktime.find_by_time(user: self, begin_at: begin_at, end_at: end_at, task: task)
      if worktimes.present?
        tasks << {
          id: task.id,
          name: task.name,
          time: worktimes.reduce(0) { |total,worktime| total += worktime.time_worked}
        }
      end
    end
    tasks
  end
end
