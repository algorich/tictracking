require 'spec_helper'

feature 'Worktime' do
  background do
    @user = create :user
    @user.confirm!
    login_as @user
    @project = create :project, users: [@user]
  end

  context 'create' do
    scenario 'successfully create worktime' do
      @task = create :task, project: @project
      @worktime = create :worktime, user: @user, task: @task
      visit project_path(@project.id)
      time = Time.local(2008, 9, 1, 10, 5, 0)
      Timecop.freeze(time)
      click_button 'Begin'
      expect(page).to have_content '2008-09-01 13:05:00 UTC'
    end
  end
end