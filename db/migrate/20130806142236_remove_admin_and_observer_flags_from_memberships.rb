class RemoveAdminAndObserverFlagsFromMemberships < ActiveRecord::Migration
  def up
    remove_column :memberships, :admin
    remove_column :memberships, :observer
  end

  def down
    add_column :memberships, :admin, :boolean
    add_column :memberships, :observer, :boolean
  end
end
