require 'spec_helper'

describe Project do
  it { should_not have_valid(:name).when(nil) }
  it { should_not have_valid(:user_ids).when(nil) }
  it { should have_many(:users).through(:memberships) }

  describe '#admins' do
    it "should return project's admin" do
      # user = create(:user_confirmed)
      # membership = create(:membership, user: user, admin: true)
      # project = membership.project

      # expect(project.admins).to include(user)
    end
  end
end
