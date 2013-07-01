require 'spec_helper'

describe Project do
  it { should have_many(:users).through(:memberships) }

  it { should_not have_valid(:name).when(nil) }

  it 'validate membership presence' do
    expect(subject.valid?).to be_false
    expect(subject.errors[:memberships]).to eq(["can't be blank"])
  end

  describe '#set_admin' do
    it 'if user already have a membership, set it as admin' do
      user = create(:user)
      project = Project.new(name: 'some')
      project.memberships.build(user: user, admin: false)
      project.save!

      membership = Membership.where(project_id: project.id, user_id: user.id).first
      expect(membership).to_not be_admin

      project.set_admin(user)
      expect(membership.reload).to be_admin
    end

    it 'if user do not have a membership, create one as admin' do
      user = build(:user_confirmed)
      project = Project.new

      project.set_admin(user)

      membership = project.memberships.last
      expect(membership.admin).to be_true
      expect(membership.user).to eq(user)
    end
  end

  describe '#can_add?' do
    it 'should return true if the user is not in the project' do
      project = create(:project)
      user = create(:user)

      expect(project.can_add?(user)).to be_true
      project.users << user
      expect(project.can_add?(user)).to be_false
    end
  end

  describe 'if destroy project' do
    it 'should destroy tasks, worktimes and membership' do
      Task.destroy_all
      user = create(:user)
      project = create(:project)
      task = create(:task, project: project)
      worktime = create(:worktime, user: user, task: task )
      membership = create(:membership, user: user, project: project, admin: true)
      project.destroy
      expect { Project.find(project.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Worktime.find(worktime.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
