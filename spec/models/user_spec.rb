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

  describe '#latest' do
    it 'should return the lastet tasks updated' do
      user = create(:user_confirmed)
      project_1 = create(:project, users: [user])
      task_1 = create(:task, project: project_1, name: 'Task 1')
      task_2 = create(:task, project: project_1, name: 'Task 2')
      task_3 = create(:task, project: project_1, name: 'Task 3')

      create(:worktime, user: user, task: task_1)
      create(:worktime, user: user, task: task_3)
      create(:worktime, user: user, task: task_2)

      expect(user.latest(2, :tasks)).to include(task_3, task_2)

      create(:worktime, user: user, task: task_1)
      expect(user.latest(2, :tasks)).to include(task_1, task_2)
    end

    it 'should return the lastet projects updated' do
      user = create(:user_confirmed)
      project_1 = create(:project, users: [user])
      project_2 = create(:project, users: [user])
      project_3 = create(:project, users: [user])

      expect(user.latest(2, :projects)).to include(project_3, project_2)

      create(:task, project: project_1)
      expect(user.latest(2, :projects)).to include(project_1, project_3)
    end
  end

  describe '#exists_pending_worktimes?' do
    it 'should return true or false' do
      goku = create(:user_confirmed)
      task = create(:task, name: 'Ressurect Kuririn')
      expect(goku.exists_pending_worktimes?(task)).to be_false

      worktime = create(:worktime, user: goku, task: task)
      expect(goku.exists_pending_worktimes?(task)).to be_false

      worktime = create(:worktime, user: goku, end: nil, task: task)
      expect(goku.exists_pending_worktimes?(task)).to be_true
    end
  end
end