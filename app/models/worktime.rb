class Worktime < ActiveRecord::Base
  belongs_to :user
  belongs_to :task

  attr_accessible :begin, :end, :user, :user_id, :task, :task_id

  validates :begin, presence: true
  validates :user, :task, presence: true
end