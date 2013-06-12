class CreateWorktime < ActiveRecord::Migration
  def change
    create_table :worktimes do |t|
      t.datetime :begin
      t.datetime :end
      t.references :user
      t.references :task
      t.timestamps
    end
  end
end
