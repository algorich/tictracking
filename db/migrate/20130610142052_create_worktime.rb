class CreateWorktime < ActiveRecord::Migration
  def change
    create_table :worktimes do |t|
      t.datetime :beginning
      t.datetime :finish
      t.references :user
      t.references :task
      t.timestamps
    end
  end
end
