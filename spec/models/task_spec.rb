require 'spec_helper'

describe Task do
  it { should_not have_valid(:name).when(nil, '') }
  it { should_not have_valid(:project).when(nil) }
  it { should have_many(:worktimes).dependent(:destroy) }

  it 'should_not have equal names' do
    Task.create name:'Ro', project: Project.new
    expect(subject).to_not have_valid(:name).when('Ro')
    expect(subject.errors[:name]).to include('has already been taken')
  end
end