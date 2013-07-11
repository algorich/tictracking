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

    login_as @user, scope: :user
    visit project_path(@project)
  end

  context 'Start', js:true do
    scenario 'successfully play worktime' do
      start = find("#app-tasks a[href=\"/tasks/#{@task.id}/worktimes\"]")
      start.click
      expect(page).to have_content Time.now.utc.to_s
    end
  end

  context 'Stop', js:true do
    scenario 'successfully stop worktime' do
      pending 'mudar stop para uma ação propria no controller'
      start = find("#app-tasks a[href=\"/tasks/#{@task.id}/worktimes\"]")
      stop = find("#app-tasks a[data-method=\"put\"]")
      start.click
      sleep(1)
      stop.click
      expect(page).to have_content Time.now.utc.to_s
      expect(page).to have_content Time.now.utc.to_s
    end
  end

  context 'edit' do
    scenario 'should edit a worktime' do
      pending 'Descobrir pq o find não pega'
      membership = create(:membership, project: @project, user: @user)
      visit edit_task_worktime_path(@task, @worktime)

      fill_in '#worktime_begin', with: (@begin_time - 2000.years)

      within('#begin_' + @worktime.id.to_s) do
        expect(page).to have_content(@begin_time - 2000.years)
      end
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
      link_destroy = page.find(:xpath,".//a[@href=\"/tasks/#{@task.id}/worktimes/#{@worktime.id}\" and @data-method=\"delete\"]")
      link_destroy.click

      expect(page).to_not have_content 'Deleted'
      expect(page).to have_content('You are not authorized to access this page.')
    end
  end

  context 'listning' do
    scenario 'only members should edit, destroy and read worktime' do
      link_edit_begin_worktime = page.find('#edit_begin_' + @worktime.id.to_s)
      link_edit_end_worktime = page.find('#edit_end_' + @worktime.id.to_s)
      expect(link_edit_begin_worktime).to be_visible
      expect(link_edit_end_worktime).to be_visible

      logout :user

      user = create(:user_confirmed)
      login_as user
      visit "/tasks/#{@task.id}/worktimes/#{@worktime.id}/edit"
      expect(page).to have_content 'You are not authorized to access this page.'
    end
  end
end