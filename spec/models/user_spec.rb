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
end