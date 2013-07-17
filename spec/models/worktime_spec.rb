require 'spec_helper'

describe Worktime do
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
      expect(worktime.pending_worktime).to be_true
    end

    it 'failure' do
      worktime = create :worktime
      expect(worktime.pending_worktime).to be_false
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
      worktime = create(:worktime, begin: now, end: now + 3.hours)
      expect(worktime.reload.time_worked).to eq(3.hours)

      worktime = create(:worktime, begin: now, end: nil)
      expect(worktime.reload.time_worked).to eq(nil)

      worktime.end = now + 3.hours
      worktime.save
      expect(worktime.reload.time_worked).to eq(3.hours)
    end
  end

  context '#time_worked_formatted' do
    it 'should show the time in minutes' do
      worktime = create :worktime, begin: Time.now, end: Time.now + 30.minutes
      expect(worktime.time_worked_formatted).to eq('30 minutes')
    end
  end
end