class ChangeAttributesToMembership < ActiveRecord::Migration
  def up
    change_column :memberships, :admin, :boolean, :default => false
  end

  def down
    change_column :memberships, :admin, :boolean, :default => nil
  end
end
