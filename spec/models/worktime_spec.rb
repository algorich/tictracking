require 'spec_helper'

describe Worktime do
  describe '#stopped_worktime' do
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
      expect(worktime.send(:positive_time)).to be_true

      worktime = Worktime.create(:finish => Time.now - 20.minutes,
        :beginning => Time.now, user: User.new, task: Task.new)
      expect(worktime.send(:positive_time)).to be_false
    end

    it 'should time beginning bigger time nil' do
      user = create :user_confirmed
      task = create :task
      worktime = Worktime.create(:beginning => Time.now, user: user, task: task)
      worktime.update_attributes(finish: nil)
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

  describe '#finished?' do
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

  describe '#pending_worktime' do
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

  context 'validations' do
    it { should_not have_valid(:beginning).when(nil, '') }
    it { should_not have_valid(:user).when(nil) }
    it { should_not have_valid(:task).when(nil) }
  end

  describe '#set_time_worked' do
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

  context 'create worktime without ends another worktime' do
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