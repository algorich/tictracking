class AddTimeWorkedToWorktimes < ActiveRecord::Migration
  def change
    add_column :worktimes, :time_worked, :integer, default: 0
  end
end
