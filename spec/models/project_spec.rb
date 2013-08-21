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


    describe '#get_all_time_worked' do
      it 'should return the sum of all time worked by projects users' do
        project_info = @world_salvation.reload.get_all_time_worked(
          begin_at: @world_salvation.created_at,
          end_at: Time.now)

        expect(project_info[:time_worked_by_all]).to eq 17.minutes
        expect(project_info[:users].keys).to eq @world_salvation.users
      end
    end
  end
end
