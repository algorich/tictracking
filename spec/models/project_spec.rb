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

  context 'calculation time worked' do
    before(:each) do
      @goku = create(:user_confirmed)
      @world_salvation = create(:project, name: 'World Salvation', users: [@goku])
      @task = create(:task, project: @world_salvation, name: 'Task 1')
      now = Time.now
      worktime = create(:worktime, task: @task, begin: now, end: now + 2.minutes,
        user: @goku )
      worktime = create(:worktime, task: @task, begin: now, end: now + 3.minutes,
        user: @goku )

      @task_2 = create(:task, project: @world_salvation, name: 'Task 2')
      worktime = create(:worktime, task: @task_2, begin: now, end: now + 10.minutes,
        user: @goku )
    end

    describe '#time_worked' do
      it 'should return the all time worked by user in all tasks' do
        expect(@world_salvation.time_worked(@goku)).to eq(15.minutes)
      end
    end

    describe '#tasks_times' do
      it 'should return an hash with tasks name and time_worked' do
        kuririn = create(:user_confirmed, name: 'kuririn')
        create(:membership, project: @world_salvation, user: kuririn)
        die = create(:task, project: @world_salvation, name: 'die')
        worktime = create(:worktime, task: die, user: kuririn )

        hash = @world_salvation.tasks_times(@goku)
        expect(hash).to eq(
          [
            {
              id: @task.id,
              name: @task.name,
              time:  5.minutes
            },
            {
              id: @task_2.id,
              name: @task_2.name,
              time: 10.minutes
            }
          ])
      end
    end
  end
end
