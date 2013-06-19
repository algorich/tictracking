require 'spec_helper'

describe User do
  it { should have_many(:projects).through(:memberships) }

  describe '#admin?' do
    it "should return true if user is a project's admin" do
      user = create(:user_confirmed)
      project_1 = create(:project)
      project_2 = create(:project)

      create(:membership, user: user, project: project_1, admin: true)
      create(:membership, user: user, project: project_2, admin: false)

      expect(user.admin?(project_1)).to eq(true)
      expect(user.admin?(project_2)).to eq(false)
    end
  end

  describe '#member?' do
    it "should return true if user is a project's member" do
      user = create(:user_confirmed)
      project_1 = create(:project)
      project_2 = create(:project)
      create(:membership, user: user, project: project_1)

      expect(user.member?(project_1)).to be_true
      expect(user.member?(project_2)).to be_false
    end
  end

  describe '#latest_tasks' do
    it 'should return the lastet tasks' do
      user = create(:user_confirmed)
      membership_1 = create(:membership, user: user)
      membership_2 = create(:membership, user: user)
      membership_3 = create(:membership, user: user)

      expect(user.latest_tasks(2)).to eq([membership_3, membership_2])
    end
  end
end