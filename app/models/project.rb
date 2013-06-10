class Project < ActiveRecord::Base
  attr_accessible :name, :user_ids

  has_many :tasks
  has_many :memberships
  has_many :users, through: :memberships
  validates :name, presence: true

end
