class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :user
      t.references :project
      t.boolean :admin

      t.timestamps
    end
    add_index :memberships, :user_id
    add_index :memberships, :project_id
  end
end
