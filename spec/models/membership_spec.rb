require 'spec_helper'

describe Membership do

  describe '#toggle_admin!' do
    it 'should toggle the admin' do
      membership = create(:membership, role:'common_user')

      expect(membership.admin?).to be_false
      membership.toggle_admin!
      expect(membership.reload.admin?).to be_true
    end
  end

  describe '#can_toggle_admin?' do
    it 'should return false case the project has only one admin' do
      project = create :project
      membership_1 = project.memberships.first
      membership_2 = create :membership, role: 'admin', project: project

      expect(membership_2.send(:can_toggle_admin?)).to be_true

      membership_1.role = 'common_user'
      membership_1.save
      expect(membership_2.send(:can_toggle_admin?)).to be_false
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
  end
end
