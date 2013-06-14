require 'spec_helper'

describe Project do
  it { should_not have_valid(:name).when(nil) }
  it { should_not have_valid(:user_ids).when(nil) }
  it { should have_many(:users).through(:memberships) }

  describe '#set_admin' do
    it "should associate an admin to the project" do
      user = create(:user_confirmed)
      project = create(:project)

      project.set_admin(user)

      expect(user.admin?(project)).to be_true
    end
  end
end
