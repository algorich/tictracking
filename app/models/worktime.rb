class Worktime < ActiveRecord::Base
  belongs_to :user
  belongs_to :task, touch: true

  attr_accessible :begin, :end, :user, :user_id, :task, :task_id

  validates :begin, presence: true
  validates :user, :task, presence: true
  validate :pending_worktime, on: :create

  def pending_worktime
    errors.add(:base, 'a pending worktime already exists') if exists_pending_worktimes?
  end

  def finished?
    self.end.present?
  end

  private

  def exists_pending_worktimes?
    Worktime.where(user_id: self.user, task_id: self.task, end: nil).any?
  end
end