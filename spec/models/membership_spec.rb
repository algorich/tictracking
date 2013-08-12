require 'spec_helper'

describe Membership do

  describe '#set_role!' do
    it 'should change role' do
      membership = create(:membership, role:'common_user')

      expect(membership.admin?).to be_false
      membership.set_role!('admin')
      expect(membership.reload.admin?).to be_true
    end

    it 'should not change role from admin if the project does not have more admins' do
      user_1 = create :user_confirmed
      user_2 = create :user_confirmed
      project = create :project, users: [user_1]
      membership_1 = user_1.membership(project)
      membership_2 = create(:membership, user: user_2, project: project)

      expect(user_1.admin?(project)).to be_true
      expect(user_2.admin?(project)).to be_false
      expect(membership_1.set_role!('observer')).to be_false

      expect(user_1.admin?(project)).to be_true
      expect(user_2.admin?(project)).to be_false
      expect(membership_2.set_role!('admin')).to be_true

      expect(user_1.admin?(project)).to be_true
      expect(user_2.admin?(project)).to be_true
      expect(membership_1.set_role!('observer')).to be_true

      expect(user_1.admin?(project)).to be_false
      expect(user_2.admin?(project)).to be_true
    end
  end

  describe '#can_remove_admin?' do
    it 'should return false case the project has only one admin' do
      project = create :project
      membership_1 = project.memberships.first
      membership_2 = create :membership, role: 'admin', project: project

      expect(membership_2.send(:can_remove_admin?)).to be_true

      membership_1.role = 'common_user'
      membership_1.save
      expect(membership_2.send(:can_remove_admin?)).to be_false
    end
  end

  context 'Roles' do
    it { should_not have_valid(:role).when(nil) }
    it 'should have the roles: admin, observer and common_user' do
      expect(Membership::ROLES).to include('admin', 'observer', 'common_user')
    end

    describe '#admin?' do
      it 'should return true if the membership has a role admin' do
        expect(subject.admin?).to be_false
        subject.role = 'admin'
        expect(subject.admin?).to be_true
      end
    end

    describe '#observer?' do
      it 'should return true if the membership has a role observer' do
        expect(subject.observer?).to be_false
        subject.role = 'observer'
        expect(subject.observer?).to be_true
      end
    end
  end
end
