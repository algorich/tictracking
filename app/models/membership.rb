class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  attr_accessible :admin

  def toggle_admin!
    self.admin = !self.admin
    self.save
  end
end
