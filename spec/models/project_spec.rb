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

      expect(project.can_add?(nil)).to be_false
      expect(project.errors[:user].first).to eq("User can't be blank!")

      expect(project.can_add?(user)).to be_true
      project.users << user
      expect(project.can_add?(user)).to be_false
      expect(project.errors[:user].first).to eq('User already in this project')
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
      @some_day = Time.local(2001, 2, 3, 1, 2, 3)

      Timecop.freeze(@some_day - 1.day) do
        @day_before_some_day = now = Time.now

        @goku = create(:user_confirmed)
        @world_salvation = create(:project, name: 'World Salvation', users: [@goku])
        @task = create(:task, project: @world_salvation, name: 'Task 1')

        worktime = create(:worktime, task: @task, beginning: now, finish: now + 2.minutes,
          user: @goku )
        worktime = create(:worktime, task: @task, beginning: now, finish: now + 3.minutes,
          user: @goku )
      end

      Timecop.freeze(@some_day) do
        now = Time.now

        #goku
        @task_2 = create(:task, project: @world_salvation, name: 'Task 2')
        worktime = create(:worktime, task: @task_2, beginning: now, finish: now + 10.minutes,
          user: @goku )

        @kuririn = create(:user_confirmed, name: 'kuririn')
        create(:membership, project: @world_salvation, user: @kuririn)
        @nothing = create(:task, project: @world_salvation, name: 'nothing')
        worktime = create(:worktime, task: @nothing, beginning: now, finish: now + 2.minutes,
          user: @kuririn )
      end
    end

    describe '#filter' do
      it 'should return a hash with key eq user and value eq to tasks filtered by time' do
        hash = @world_salvation.filter(users: [@goku, @kuririn], begin_at: @some_day, end_at: (@some_day + 1.day))
        expect(hash).to eq({
          @goku => [@task_2],
          @kuririn => [@nothing]
        })

        @piccolo = create(:user_confirmed, name: 'piccolo')
        create(:membership, project: @world_salvation, user: @piccolo)

        hash = @world_salvation.filter(users: [@piccolo], begin_at: Time.now, end_at: (Time.now + 1.day))
        expect(hash).to eq({ @piccolo => [] })
      end
    end

    describe '#filter_tasks_by' do
      it  "should return user's tasks and worktimes between times" do
        tasks = @world_salvation.send(:filter_tasks_by, @goku, @day_before_some_day, @some_day - 1.minute)
        expect(tasks).to include(@task)
        expect(tasks).to_not include(@task_2, @nothing)

        tasks = @world_salvation.send(:filter_tasks_by, @goku, @some_day, @some_day + 1.day)
        expect(tasks).to include(@task_2)
        expect(tasks).to_not include(@task, @nothing)

        tasks = @world_salvation.send(:filter_tasks_by, @kuririn, @some_day, @some_day + 1.day)
        expect(tasks).to include(@nothing)
        expect(tasks).to_not include(@task, @task_2)
      end
    end

    describe '#time_worked_by_all' do
      it 'should return the time worked by all users for a hash like { user: tasks }' do
        hash = @world_salvation.filter(users: [@goku], begin_at: (@some_day - 3.days), end_at: (@some_day + 1.day))
        expect(@world_salvation.time_worked_by_all(hash)).to eq(15.minutes)

        hash = @world_salvation.filter(users: [@goku, @kuririn], begin_at: (@some_day - 3.days), end_at: (@some_day + 1.day))
        expect(@world_salvation.time_worked_by_all(hash)).to eq(17.minutes)
      end
    end
  end
end
