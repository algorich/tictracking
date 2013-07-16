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

  context 'should have a end date' do
    it { should have_valid(:end).when(Time.now + 1.day) }
  end

  context 'should have a user' do
    it { should have_valid(:user).when(User.new) }
    it { should_not have_valid(:user).when(nil) }
  end

  context 'should have a task' do
    it { should have_valid(:task).when(Task.new) }
    it { should_not have_valid(:task).when(nil) }
  end
end