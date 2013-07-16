class Worktime < ActiveRecord::Base
  belongs_to :user
  belongs_to :task, touch: true

  attr_accessible :begin, :end, :user, :user_id, :task, :task_id
  attr_accessor :skip_stopped_validation

  validates :begin, presence: true
  validates :user, :task, presence: true
  validate :pending_worktime, on: :create
  validate :stopped_worktime, on: :update

  def finished?
    self.end.present?
  end

  def was_finished?
    self.end_was.present?
  end

  private

  def stopped_worktime
    if self.was_finished? and !self.skip_stopped_validation
      errors.add(:base, "Worktime already stopped")
    end
  end

  def pending_worktime
    errors.add(:base, 'Worktime must be stopped') if exists_pending_worktimes?
  end

  def exists_pending_worktimes?
    Worktime.where(user_id: self.user, task_id: self.task, end: nil).any?
  end
end