class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.references :project
      t.references :user
      t.timestamps
    end
  end
end
