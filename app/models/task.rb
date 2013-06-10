class Task < ActiveRecord::Base
  attr_accessible :name, :project, :project_id
  belongs_to :project

  validates :name, presence: true, uniqueness: true
  validates :project, presence: true
end
