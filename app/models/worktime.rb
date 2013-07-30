class Worktime < ActiveRecord::Base
  belongs_to :user
  belongs_to :task, touch: true

  attr_accessible :beginning, :finish, :user, :user_id, :task, :task_id
  attr_accessor :skip_stopped_validation

  validates :beginning, presence: true
  validates :user, :task, presence: true
  validate :pending_worktime, on: :create
  validate :stopped_worktime, on: :update
  validate :positive_time, on: :update
  validate :timer_create_project, on: :update
  validate :all_finished?, on: :create
  after_validation :set_time_worked

  def self.find_by_time(user: user, begin_at: begin_at, end_at: end_at, task: task)
    self.where{
      (user_id.eq my{user.id}) &
      (task_id.eq my{task.id}) &
      (self.beginning.gteq my{begin_at}) &
      (self.finish.lteq my{end_at})
    }
  end

  def pending_worktime
    errors.add(:base, 'a pending worktime already exists') if exists_pending_worktimes?
  end

  def finished?
    self.finish.present?
  end

  def was_finished?
    self.finish_was.present?
  end

  def time_worked_formatted
    time = self.time_worked.nil? ? 0 : self.time_worked
    (time/(1.0).minute).round.to_s + ' minutes'
  end

  private

  def timer_create_project
    if self.beginning <= self.task.project.created_at or self.finish <= task.project.created_at
      errors.add(:base, 'End time or last time cant be less than time of the create project')
    end
  end

  def positive_time
    if self.beginning > self.finish
      errors.add(:base, "End time can't be less than beginning time")
    end
  end

  def stopped_worktime
    if self.was_finished? and !self.skip_stopped_validation
      errors.add(:base, "Worktime already stopped")
    end
  end

  def pending_worktime
    errors.add(:base, 'Worktime must be stopped') if exists_pending_worktimes?
  end

  def exists_pending_worktimes?
    Worktime.where(user_id: self.user, task_id: self.task, finish: nil).any?
  end

  def set_time_worked
    self.time_worked = (self.finish - self.beginning).round unless self.finish.nil?
  end

  def all_finished?
    errors.add(:base, 'You have an ongoing worktime') if any_not_finished?
  end

  def any_not_finished?
    worktimes = Worktime.where {
      (user_id.eq my{self.user}) &
      (finish.eq nil)
    }.any?
  end
end