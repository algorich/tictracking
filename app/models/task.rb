class Task < ActiveRecord::Base
  belongs_to :project
  has_many :worktimes, dependent: :destroy

  attr_accessible :name, :project, :project_id

  validates :name, presence: true, uniqueness: true
  validates :project, presence: true
end