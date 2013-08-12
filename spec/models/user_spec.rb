require 'spec_helper'

describe User do
  it { should have_many(:projects).through(:memberships) }

  describe '#admin?' do
    it "should return true if user is a project's admin" do
      user = create(:user_confirmed)
      project_1 = create(:project)
      project_2 = create(:project)

      create(:membership, user: user, project: project_1, role: 'admin')
      create(:membership, user: user, project: project_2, role: 'common_user')

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

      worktime = create(:worktime, user: goku, finish: nil, task: task)
      expect(goku.exists_pending_worktimes?(task)).to be_true
    end
  end

  describe '#observer?' do
    it 'should return true or false' do
      observer = create(:user_confirmed)
      project = create(:project)
      create(:membership, project: project, user: observer)
      expect(observer.observer?(project)).to be_false

      create(:membership, project: project, user: observer, role: 'observer')
      expect(observer.observer?(project)).to be_true
    end
  end

  describe '#role_in' do
    it 'should return the role in the project' do
      project = create(:project)
      user = create(:user_confirmed)
      expect(user.role_in?(project)).to be_nil

      membership = create(:membership, project: project, user: user, role: 'common_user')
      expect(user.role_in?(project)).to eq('common_user')

      membership.update_attribute(:role, 'admin')
      expect(user.role_in?(project)).to eq('admin')
    end
  end

  describe '#membership' do
    it 'should return the membership of the project' do
      project = create(:project)
      user = create(:user_confirmed)
      membership = create(:membership, project: project, user: user)

      expect(user.membership(project)).to eq(membership)
    end
  end

  context 'time worked' do
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
      end
    end

    describe '#time_worked_on' do
      it 'should return an hash with the all time worked in all tasks and the tasks' do
        world_salvation_time_worked = @goku.time_worked_on(
          project: @world_salvation,
          begin_at: @world_salvation.created_at,
          end_at: Time.now)

        expect(world_salvation_time_worked[:time_worked_at_all]).to eq(15.minutes)
        expect(world_salvation_time_worked[:tasks].size).to eq(2)
      end
    end

    describe '#get_tasks_time_worked' do
      it "should return an array with task's id, name and time_worked" do

        array = @goku.send(:get_tasks_time_worked, @world_salvation, @world_salvation.created_at, Time.now)
        expect(array.size).to eq(2)

        expect(array).to eq(
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