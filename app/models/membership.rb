class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  attr_accessible :admin
end
