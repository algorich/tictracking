class AddObserverToUser < ActiveRecord::Migration
  def change
    add_column :memberships, :observer, :boolean
  end
end
