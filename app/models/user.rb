class User < ActiveRecord::Base
  has_many :worktimes

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
   :trackable, :validatable, :confirmable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
end
