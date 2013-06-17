require 'spec_helper'

describe Project do
  it { should have_many(:users).through(:memberships) }

  it { should_not have_valid(:name).when(nil) }

  it 'validate memberships presence' do
    expect(subject.valid?).to be_false
    expect(subject.errors[:memberships]).to eq(["can't be blank"])
  end


  describe '#set_admin' do
    it "should associate an admin to the project" do
      user = build(:user_confirmed)
      project = build(:project)

      project.set_admin(user)

      membership = project.memberships.last
      expect(membership.admin).to be_true
      expect(membership.user).to eq(user)
    end
  end
end
