require 'spec_helper'

feature 'Worktime' do
  background do
    @user = create :user
    @user.confirm!
    login_as @user
    @project = create :project, users: [@user]
    @task = create :task, project: @project
    @worktime = create :worktime, user: @user, task: @task
    visit project_path(@project.id)
  end

  after do
    Timecop.return
  end

  context 'create' do
    scenario 'successfully create worktime' do
      time = Time.local(2008, 9, 1, 10, 5, 0)
      Timecop.freeze(time)
      click_button 'Continue'
      expect(page).to have_content '2008-09-01 13:05:00 UTC'
    end
  end

  context 'stop' do
    scenario 'successfully stop worktime' do
      time = Time.local(2013, 6, 1, 10, 5, 0)
      Timecop.freeze(time)
      click_button 'Continue'
      expect(page).to have_content 'Successfully'
      time = Time.local(2013, 6, 1, 11, 5, 0)
      Timecop.freeze(time)
      click_button 'Stop'
      expect(page).to have_content '2013-06-01 14:05:00 UTC'
    end
  end

end