class Task < ActiveRecord::Base
  belongs_to :project, touch: true
  has_many :worktimes, dependent: :destroy

  attr_accessible :name, :project, :project_id

  validates :name, presence: true, uniqueness: { scope: :project_id }
  validates :project, presence: true
end