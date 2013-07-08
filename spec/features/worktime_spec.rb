require 'spec_helper'

feature 'Worktime' do
  background do
    @user = create :user_confirmed
    @yoda = create :user_confirmed, email: 'yoda@jedi.com'
    @goten = create :user_confirmed, email: 'goten@dbz.com'

    @project = create :project, users: [@user, @goten]
    @task = create :task, project: @project
    @begin_time = Time.local(2013, 6, 1, 11, 5)
    @end_time = Time.local(2012, 6, 1, 11, 5)
    @worktime = create :worktime, user: @user, task: @task, begin: @begin_time, end: @end_time

    login_as @user
    visit project_path(@project)
  end

  context 'create', js:true do
    scenario 'successfully play worktime' do
      click_button 'Continue'
      expect(page).to have_content Time.now.utc.to_s
    end
  end

  context 'stop', js:true do
    scenario 'successfully stop worktime' do
      click_button 'Continue'
      expect(page).to have_content Time.now.utc
      sleep(1)
      click_button 'Stop'
      expect(page).to have_content Time.now.utc.to_s
    end
  end

  context 'edit' do
    scenario 'should edit a worktime' do
      membership = create(:membership, project: @project, user: @user)
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

      expect(@worktime.end.day).to eq(@begin_time.day)
      # @worktime.end.day
      # @worktime.end.day
    end

    scenario 'users that do not belong to project' do
      login_as @yoda
      visit edit_task_worktime_path(@task, @worktime)
      expect(page).to have_content('You are not authorized to access this page.')
    end

    scenario 'another users that belong to project' do
      login_as @goten
      visit edit_task_worktime_path(@task, @worktime)
      expect(page).to have_content('You are not authorized to access this page.')
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

    scenario 'users that do not belong to project' do
      login_as @yoda
      visit project_path(@project.id)
      expect(page).to have_content('You are not authorized to access this page.')
    end

    scenario 'another users that belong to project' do
      login_as @goten
      visit project_path(@project)
      expect(current_path).to eq(project_path(@project))

      link_destroy = page.find(:xpath,
       ".//a[@href=\"/tasks/#{@task.id}/worktimes/#{@worktime.id}\"
        and @data-method=\"delete\"]")
      link_destroy.click

      expect(page).to_not have_content 'Deleted'
      expect(page).to have_content('You are not authorized to access this page.')
    end
  end

  context 'listning' do
    scenario 'only members should edit, destroy and read worktime' do
      link_edit = page.find(:xpath,
       ".//a[@href=\"/tasks/#{@task.id}/worktimes/#{@worktime.id}/edit\"]")
      expect(link_edit).to be_visible

      click_link 'Sign out'

      user = create(:user_confirmed)
      login_as user
      visit "/tasks/#{@task.id}/worktimes/#{@worktime.id}/edit"
      expect(page).to have_content 'You are not authorized to access this page.'
    end
  end
end