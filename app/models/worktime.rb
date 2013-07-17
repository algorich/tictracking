class Worktime < ActiveRecord::Base
  belongs_to :user
  belongs_to :task, touch: true

  attr_accessible :begin, :end, :user, :user_id, :task, :task_id

  validates :begin, presence: true
  validates :user, :task, presence: true
  validate :pending_worktime, on: :create
  after_validation :set_time_worked

  def pending_worktime
    errors.add(:base, 'a pending worktime already exists') if exists_pending_worktimes?
  end

  def finished?
    self.end.present?
  end

  def time_worked_formatted
    time = self.time_worked.nil? ? 0 : self.time_worked
    (time/(1.0).minute).round.to_s + ' minutes'
  end

  private

  def exists_pending_worktimes?
    Worktime.where(user_id: self.user, task_id: self.task, end: nil).any?
  end

  def set_time_worked
    self.time_worked = (self.end - self.begin).round unless self.end.nil?
  end
end