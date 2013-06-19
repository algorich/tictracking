require 'spec_helper'

feature 'Worktime' do
  background do
    @user = create :user_confirmed
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
      Timecop.return
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

  context 'edit' do
    scenario 'should edit a worktime' do
      begin_time = Time.local(2013, 6, 1, 11, 5, 0)
      end_time = Time.local(2012, 6, 1, 11, 5, 0)
      worktime = create(:worktime, begin: begin_time, end: end_time)

      link_edit = page.find(:xpath,
       ".//a[@href=\"/tasks/#{@task.id}/worktimes/#{@worktime.id}/edit\"]")
      link_edit.click

      select('2010', from: 'worktime_begin_1i') # year
      select('May', from: 'worktime_begin_2i') # month
      select('9', from: 'worktime_begin_3i') # day
      select('22', from: 'worktime_begin_4i') # hours
      select('04', from: 'worktime_begin_5i') # min

      select('2011', from: 'worktime_end_1i') # year
      select('May', from: 'worktime_end_2i') # month
      select('9', from: 'worktime_end_3i') # day
      select('22', from: 'worktime_end_4i') # hours
      select('04', from: 'worktime_end_5i') # min

      click_button 'Update Worktime'

      expect(page).to have_content '2010-05-09 22:04:00 UTC'
      expect(page).to have_content '2011-05-09 22:04:00 UTC'
    end
  end

  context 'destroy' do
    scenario 'should destroy a worktime' do
      link_destroy = page.find(:xpath,
       ".//a[@href=\"/tasks/#{@task.id}/worktimes/#{@worktime.id}\"
        and @data-method=\"delete\"]")
      link_destroy.click

      expect(page).to have_content 'Deleted'
    end
  end

  # context 'listning' do
  #   scenario 'only members should edit, destroy and read worktime' do
  #     link_edit = page.find(:xpath,
  #      ".//a[@href=\"/tasks/#{@task.id}/worktimes/#{@worktime.id}/edit\"]")

  #   end
  # end
end