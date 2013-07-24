require 'spec_helper'

feature 'Worktime' do
  background do
    @user = create :user_confirmed
    @yoda = create :user_confirmed, email: 'yoda@jedi.com'
    @goten = create :user_confirmed, email: 'goten@dbz.com'

    @project = create :project, users: [@user, @goten]
    @task = create :task, project: @project
    @begin_time = Time.local(2013, 6, 1, 11, 5)
    @end_time = Time.local(2014, 6, 1, 11, 5)
    @worktime = create :worktime, user: @user, task: @task, begin: @begin_time, end: @end_time

    login_as @user, scope: :user
    visit project_path(@project)
  end

  context 'Start', js:true do
    scenario 'successfully play worktime' do
      @start = find("#app-tasks a[href=\"/tasks/#{@task.id}/worktimes\"]")
      @start.click
      expect(page).to have_content Time.now.utc.to_s
    end

    scenario 'should show only if not exist any open worktime' do
      start = find("#actions a[data-method=\"post\"]")
      expect(start).to be_visible
      expect(page).to_not have_css("#actions a[data-method=\"put\"]")

      start.click
      sleep(1)
      expect(page).to have_css("#actions a[data-method=\"put\"]")

      visit project_path(@project)
      expect(page).to_not have_css("#actions a[data-method=\"post\"]") #start
      expect(page).to have_css("#actions a[data-method=\"put\"]") #stop
    end
  end

  context 'Stop', js:true do
    scenario 'successfully stop worktime' do
      start = find("#app-tasks a[href=\"/tasks/#{@task.id}/worktimes\"]")
      start.click
      sleep(1)
      stop = find("#app-tasks a[data-method=\"put\"]")
      stop.click
      expect(page).to have_content Time.now.utc.to_s
    end
  end

  context 'edit' do
    scenario 'should edit a worktime' do
      membership = create(:membership, project: @project, user: @user)
      visit edit_task_worktime_path(@task, @worktime)
      fill_in 'worktime_begin', with: "2012-10-01 10:05:00"
      click_button 'Update Worktime'

      within('#begin_' + @worktime.id.to_s) do
        expect(page).to have_content("2012-10-01 10:05:00")
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
  end

  context 'listning' do
    scenario 'only members should edit, destroy and read worktime' do
      expect(page).to have_link('', href: edit_task_worktime_path(@task,@worktime))
      expect(page).to have_link('', href: task_worktime_path(@task,@worktime)) #destroy link

      logout :user

      login_as @goten
      visit project_path(@project)

      expect(page).to_not have_link('', href: edit_task_worktime_path(@task,@worktime))
      expect(page).to_not have_link('', href: task_worktime_path(@task,@worktime)) #destroy link
    end
  end

  context 'show' do
    scenario 'should show worktimes in order by update_at' do
      within('#worktime_0') do
        expect(page).to have_content @worktime.begin
      end

      worktime_2 = create :worktime, user: @user, task: @task, begin: Time.now + 1.hours
      worktime_3 = create :worktime, user: @user, task: @task,
        begin: Time.now,
        end: Time.now + 5.minutes

      visit project_path(@project)
      within('#worktime_0') do
        expect(page).to have_content worktime_3.begin
        expect(page).to have_content '5 minutes'
      end
      within('#worktime_1') do
        expect(page).to have_content worktime_2.begin
      end
      within('#worktime_2') do
        expect(page).to have_content @worktime.begin
      end
    end
  end
end