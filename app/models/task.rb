class Task < ActiveRecord::Base
  attr_accessible :name, :project, :project_id, :user, :user_id
  belongs_to :project
  belongs_to :user

  validates :name, presence: true, uniqueness: true
  validates :user, :project, presence: true
end
