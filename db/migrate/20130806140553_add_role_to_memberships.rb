class AddRoleToMemberships < ActiveRecord::Migration
  def up
    add_column :memberships, :role, :string, default: 'common_user'

    #migrating old data
    Membership.all.each do |m|
      if m.admin?
        m.role = 'admin'
      elsif m.observer?
        m.role = 'observer'
      else
        m.role = 'common_user'
      end
      m.save
    end
  end

  def down
    #migrating old data
    Membership.all.each do |m|
      if m.role == 'admin'
        m.admin = true
      elsif m.role == 'observer'
        m.observer = true
      end
      m.save
    end

    remove_column :memberships, :role
  end
end
