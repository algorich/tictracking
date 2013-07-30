require 'spec_helper'

describe Worktime do
  context '#stopped_worktime' do
    it 'should return true if worktime stopped' do
      worktime = create :worktime
      expect(worktime.send(:stopped_worktime)).to be_true
    end

    it 'failure' do
      worktime = Worktime.create(:beginning => Time.now,
       user: User.new, task: Task.new)
      expect(worktime.send(:stopped_worktime)).to be_false
    end

    it 'should time end bigger time beginning' do
      user = create :user_confirmed
      task = create :task
      worktime = Worktime.create(:beginning => Time.now, user: user, task: task)
      worktime.update_attributes(finish: Time.now + 2.minutes)
      expect(worktime.send(:positive_time)).to be_false

      worktime = Worktime.create(:finish => Time.now - 20.minutes,
        :beginning => Time.now, user: User.new, task: Task.new)
      expect(worktime.send(:positive_time)).to be_true
    end

    it "beginning and end can't have bigger timer than project" do
      user = create :user_confirmed
      task = create :task
      project = create :project
      membership = create :membership, user: user, project: project
      worktime = Worktime.create(:finish => Time.now + 2.minutes, :beginning => Time.now,
       user: user, task: task)
      expect(worktime.send(:timer_create_project)).to be_false
    end
  end

  context '#finished?' do
    it 'should return true if worktime finished' do
      worktime = create(:worktime)
      expect(worktime.finished?).to eq(true)
    end

    it 'failure' do
      worktime = Worktime.create(:beginning => Time.now,
       user: User.new, task: Task.new)
      expect(worktime.finished?).to be_false
    end
  end

  context '#pending_worktime' do
    it 'should return true if worktime is pending' do
      worktime = Worktime.create(:beginning => Time.now,
       user: User.new, task: Task.new)
      expect(worktime.send(:pending_worktime)).to be_true
    end

    it 'failure' do
      worktime = create :worktime
      expect(worktime.send(:pending_worktime)).to be_false
    end
  end

  context 'should have a beginning date' do
    it { should_not have_valid(:beginning).when(nil, '') }
    it { should have_valid(:beginning).when(Time.now) }
  end

  context 'should have a user' do
    it { should have_valid(:user).when(User.new) }
    it { should_not have_valid(:user).when(nil) }
  end

  context 'should have a task' do
    it { should have_valid(:task).when(Task.new) }
    it { should_not have_valid(:task).when(nil) }
  end

  context '#set_time_worked' do
    it 'should return the difference between the beginning and end time' do
      subject.beginning = Time.now
      subject.finish = Time.now + 3.hours
      expect(subject.send(:set_time_worked)).to eq(3.hours)
    end

    it 'should set the time worked after the worktime finish' do
      now = Time.now
      project = create :project, created_at: now - 1.day
      task = create :task, project: project
      worktime = create(:worktime, beginning: now, finish: now + 3.hours)
      expect(worktime.reload.time_worked).to eq(3.hours)

      worktime = create(:worktime, beginning: now, finish: nil, task: task)
      expect(worktime.reload.time_worked).to eq(0)
      worktime.finish = now + 4.hours
      worktime.save
      expect(worktime.reload.time_worked).to eq(4.hours)
    end
  end

  context '#time_worked_formatted' do
    it 'should show the time in minutes' do
      worktime = create :worktime, beginning: Time.now, finish: Time.now + 30.minutes
      expect(worktime.time_worked_formatted).to eq('30 minutes')
    end
  end

  context '.find_by_time' do
    it 'filter worktimes by time' do
      today = Time.now
      yesterday = today - 1.day
      task = create(:task)
      user = create(:user_confirmed)
      worktime_1 = create :worktime, beginning: yesterday, finish: yesterday + 1.minute,
        task: task, user: user
      worktime_2 = create :worktime, beginning: today, finish: today + 1.minute,
        task: task, user: user

      worktimes = Worktime.find_by_time(user: user, task: task,
        begin_at: yesterday, end_at: today + 1.day)
      expect(worktimes).to include(worktime_1, worktime_2)

      worktimes = Worktime.find_by_time(user: user, task: task,
        begin_at: today, end_at: today + 1.day)
      expect(worktimes).to eq([worktime_2])

      worktimes = Worktime.find_by_time(user: user, task: task,
        begin_at: yesterday, end_at: today - 20.minutes)
      expect(worktimes).to eq([worktime_1])
    end
  end

  context 'create worktime' do
    before(:each) do
      @user = create :user_confirmed
      @task_1 = create :task
      @task_2 = create :task
      create :membership, user: @user, project: @task_1.project
      create :membership, user: @user, project: @task_2.project
    end

    it 'should not possible if someone is not finished in the same or another task' do
      worktime_of_user_1 = create :worktime, task: @task_1, user: @user, finish: nil

      expect(worktime_of_user_1.finished?).to be_false
      expect { create(:worktime, task: @task_1, user: @user, finish: nil) }
        .to raise_error(ActiveRecord::RecordInvalid)
      expect { create(:worktime, task: @task_2, user: @user, finish: nil) }
        .to raise_error(ActiveRecord::RecordInvalid)
    end

    describe '#any_not_finished?' do
      it 'should return true if exist some worktimenot finished with the same user' do
        worktime = create :worktime, task: @task_1, user: @user
        expect(worktime.send(:any_not_finished?)).to be_false

        create :worktime, task: @task_1, user: @user, finish: nil
        expect(worktime.send(:any_not_finished?)).to be_true
      end
    end
  end

end