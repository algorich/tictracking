class Task < ActiveRecord::Base
  belongs_to :project, touch: true
  has_many :worktimes, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :project_id }
  validates :project, presence: true

  def time_worked
    self.worktimes.reduce(0) { |total, worktime| total += worktime.time_worked }
  end
end