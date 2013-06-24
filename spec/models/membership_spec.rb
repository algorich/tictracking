require 'spec_helper'

describe Membership do

  it 'should have false by default for admin' do
    expect(Membership.create!.admin).to eq(false)
  end

  describe '#toggle_admin!' do
    it 'should toggle the admin' do
      membership = create(:membership, admin: false)

      expect(membership.admin).to be_false
      membership.toggle_admin!
      expect(membership.reload.admin).to be_true
    end
  end

  describe '#can_toggle_admin?' do
    it 'should return false case the project has only one admin' do
      project = create :project
      membership_1 = project.memberships.first
      membership_2 = create :membership, admin: true, project: project

      expect(membership_1.send(:can_toggle_admin?)).to be_true

      membership_1.toggle_admin!
      expect(membership_2.send(:can_toggle_admin?)).to be_false
    end
  end
end
