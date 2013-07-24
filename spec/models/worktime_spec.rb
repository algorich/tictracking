require 'spec_helper'

describe Worktime do
  context '#stopped_worktime' do
    it 'should return true if worktime stopped' do
      worktime = create :worktime
      expect(worktime.send(:stopped_worktime)).to be_true
    end

    it 'failure' do
      worktime = Worktime.create(:begin => Time.now,
       user: User.new, task: Task.new)
      expect(worktime.send(:stopped_worktime)).to be_false
    end

    it 'should time end bigger time begin' do
      user = create :user_confirmed
      task = create :task
      worktime = Worktime.create(:begin => Time.now, user: user, task: task)
      worktime.update_attributes(end: Time.now + 2.minutes)
      expect(worktime.send(:positive_time)).to be_false

      worktime = Worktime.create(:end => Time.now - 20.minutes,
        :begin => Time.now, user: User.new, task: Task.new)
      expect(worktime.send(:positive_time)).to be_true
    end

    it "begin and end can't have bigger timer than project" do
      user = create :user_confirmed
      task = create :task
      project = create :project
      membership = create :membership, user: user, project: project
      worktime = Worktime.create(:end => Time.now + 2.minutes, :begin => Time.now,
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
      worktime = Worktime.create(:begin => Time.now,
       user: User.new, task: Task.new)
      expect(worktime.finished?).to be_false
    end
  end

  context '#pending_worktime' do
    it 'should return true if worktime is pending' do
      worktime = Worktime.create(:begin => Time.now,
       user: User.new, task: Task.new)
      expect(worktime.send(:pending_worktime)).to be_true
    end

    it 'failure' do
      worktime = create :worktime
      expect(worktime.send(:pending_worktime)).to be_false
    end
  end

  context 'should have a begin date' do
    it { should_not have_valid(:begin).when(nil, '') }
    it { should have_valid(:begin).when(Time.now) }
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
    it 'should return the difference between the begin and end time' do
      subject.begin = Time.now
      subject.end = Time.now + 3.hours
      expect(subject.send(:set_time_worked)).to eq(3.hours)
    end

    it 'should set the time worked after the worktime finish' do
      now = Time.now
      project = create :project, created_at: now - 1.day
      task = create :task, project: project
      worktime = create(:worktime, begin: now, end: now + 3.hours)
      expect(worktime.reload.time_worked).to eq(3.hours)

      worktime = create(:worktime, begin: now, end: nil, task: task)
      expect(worktime.reload.time_worked).to eq(0)
      worktime.end = now + 4.hours
      worktime.save
      expect(worktime.reload.time_worked).to eq(4.hours)
    end
  end

  context '#time_worked_formatted' do
    it 'should show the time in minutes' do
      worktime = create :worktime, begin: Time.now, end: Time.now + 30.minutes
      expect(worktime.time_worked_formatted).to eq('30 minutes')
    end
  end

  context '.find_by_time' do
    it 'filter worktimes by time' do
      today = Time.now
      yesterday = today - 1.day
      task = create(:task)
      user = create(:user_confirmed)
      worktime_1 = create :worktime, begin: yesterday, end: yesterday + 1.minute,
        task: task, user: user
      worktime_2 = create :worktime, begin: today, end: today + 1.minute,
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
end