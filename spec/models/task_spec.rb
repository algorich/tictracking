require 'spec_helper'

describe Task do
  it { should_not have_valid(:name).when(nil, '') }
  it { should_not have_valid(:project).when(nil) }
  it { should have_many(:worktimes).dependent(:destroy) }

  it 'should not have equal names in the same project' do
    project = create(:project)
    Task.create name:'Ro', project: project
    expect(subject).to have_valid(:name).when('Ro')

    subject.project = project
    expect(subject).to_not have_valid(:name).when('Ro')
    expect(subject.errors[:name]).to include('has already been taken')
  end

  describe '#time_worked' do
    it 'should return the time worked for all worktimes' do
      user = create(:user_confirmed)
      goku = create(:user_confirmed)
      project = create(:project, users: [user, goku])
      task = create(:task, project: project)
      now = Time.now
      create(:worktime, task: task, beginning: now - 30.minutes, finish: now, user: user)
      create(:worktime, task: task, beginning: now - 40.minutes, finish: now, user: goku)

      expect(task.time_worked).to eq 70.minutes
    end
  end
end
