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
      project.memberships.build(user: user, role: :common_user)
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
      expect(membership.admin?).to be_true
      expect(membership.user).to eq(user)
    end
  end

  describe '#can_add?' do
    it 'should return true if the user is not in the project' do
      project = create(:project)
      user = create(:user_confirmed)

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
      membership = create(:membership, user: user, project: project, role: 'admin')
      project.destroy
      expect { Project.find(project.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Worktime.find(worktime.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'calculation time worked' do
    before(:each) do
      Timecop.freeze(Time.now - 1.day) do
        @goku = create(:user_confirmed)
        @world_salvation = create(:project, name: 'World Salvation', users: [@goku])
        @task = create(:task, project: @world_salvation, name: 'Task 1')
        now = Time.now
        worktime = create(:worktime, task: @task, beginning: now, finish: now + 2.minutes,
          user: @goku )
        worktime = create(:worktime, task: @task, beginning: now, finish: now + 3.minutes,
          user: @goku )

        @task_2 = create(:task, project: @world_salvation, name: 'Task 2')
        worktime = create(:worktime, task: @task_2, beginning: now, finish: now + 10.minutes,
          user: @goku )

        @kuririn = create(:user_confirmed, name: 'kuririn')
        create(:membership, project: @world_salvation, user: @kuririn)
        @nothing = create(:task, project: @world_salvation, name: 'nothing')
        worktime = create(:worktime, task: @nothing, beginning: now, finish: now + 2.minutes,
          user: @kuririn )

        @yesterday = Time.now
      end
    end

    describe '#time_worked_for' do
      it 'should return the all time worked by user in all tasks' do
        time_worked = @world_salvation.time_worked_by(user: @goku,
          begin_at: @world_salvation.created_at,
          end_at: Time.now)
        expect(time_worked).to eq(15.minutes)
      end
    end

    describe '#set_tasks_times' do
      it 'should return an hash with tasks name and time_worked' do
        kuririn = create(:user_confirmed, name: 'kuririn')
        create(:membership, project: @world_salvation, user: kuririn)
        die = create(:task, project: @world_salvation, name: 'die')
        worktime = create(:worktime, task: die, user: kuririn )

        hash = @world_salvation.send(:set_tasks_times, @goku, @world_salvation.created_at, Time.now)
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

    describe '#time_worked_for_all_users' do
      it 'should return the sum of all time worked by projects users' do
        time_worked = @world_salvation.reload.time_worked_by_all_users(
          begin_at: @world_salvation.created_at,
          end_at: Time.now)

        expect(time_worked).to eq 17.minutes
      end
    end
  end
end
