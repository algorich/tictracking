class ChangeAttributesOfWorktime < ActiveRecord::Migration
  def up
    rename_column :worktimes, :begin, :beginning
    rename_column :worktimes, :end, :finish
  end

  def down
    rename_column :worktimes, :beginning, :begin
    rename_column :worktimes, :finish, :end
  end
end
