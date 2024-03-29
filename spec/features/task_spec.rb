require 'spec_helper'

feature 'Task' do
  background do
    @user = create(:user_confirmed)
    @goku = create(:user_confirmed, email: 'goku@dbz.com')
    login_as @user
    @project = create(:project, users: [@user])
  end

  context 'create', js:true do
    background { visit project_path(@project) }

    scenario 'successfully create task and worktime' do
      time = Time.now
      fill_in 'New task', with: 'tarefa x'
      click_button 'Start'

      expect(page).to have_content('tarefa x')
      expect(page).to have_content I18n.l(time, format: :short)
    end

    scenario 'successfully create task without worktime' do
      fill_in 'New task', with: 'tarefa 1'
      click_button 'Start'
      sleep(1)

      time = Time.now + 1.hour
      fill_in 'New task', with: 'tarefa x'
      click_button 'Start'
      sleep(1)

      expect(page).to have_content('tarefa x')
      expect(page).not_to have_content I18n.l(time, format: :short)
    end

    scenario 'failure' do
      fill_in 'New task', with: ''
      click_button 'Start'
      expect(page).to have_content("can't be blank")
    end
  end

  context 'show' do
    before(:each) do
      @task_1 = Task.create(name: 'Tarefa 1', project_id: @project.id)
      @task_2 = Task.create(name: 'Tarefa 2', project_id: @project.id)
    end

    scenario 'should show a task in the view of the project' do
      visit project_path(@project)

      within "#app-tasks > div[data-id=\"#{@task_2.id}\"]" do
        expect(page).to have_content(@task_2.name)
      end

      within "#app-tasks > div[data-id=\"#{@task_1.id}\"]" do
        expect(page).to have_content(@task_1.name)
      end

      create(:worktime, user: @user, task: @task_1)
      visit project_path(@project)

      within "#app-tasks > div[data-id=\"#{@task_1.id}\"]" do
        expect(page).to have_content(@task_1.name)
      end

      within "#app-tasks > div[data-id=\"#{@task_2.id}\"]" do
        expect(page).to have_content(@task_2.name)
      end
    end

    scenario 'should not show to users that dont belong to project' do
      login_as @goku
      visit project_path(@project)
      expect(page).to have_content('goku@dbz.com')
      expect(page).to have_content('You are not authorized to access this page.')
      expect(page).not_to have_content('tarefa xx')
    end

    scenario 'should show the projects name only on dashboard_path' do
      create(:worktime, user: @user, task: @task_1)
      text = "#{@task_1.name} (#{@project.name})"

      visit dashboard_path
      expect(page).to have_content(text)

      visit project_path(@project)
      expect(page).to_not have_content(text)
    end

    scenario 'should show the time worked at all worktimes' do
      now = Time.now
      create(:membership, user: @goku, project: @project)
      create(:worktime, task: @task_1, beginning: now - 30.minutes, finish: now, user: @user)
      create(:worktime, task: @task_1, beginning: now - 40.minutes, finish: now, user: @goku)

      visit project_path(@project)

      task = find("[data-id='#{@task_1.id}']")
      within(task) do
        expect(page).to have_content(@task_1.name)
        expect(page).to have_content('Total time worked: 1 hour and 10 minutes')
      end
    end
  end

  context 'edit' do
    before do
      @task = Task.create(name: 'tarefa xy', project_id: @project.id)
      visit project_path(@project)
      expect(page).to have_content(@task.name)
      link_edit = page.find(:xpath, ".//a[@href=\"/tasks/#{@task.id}/edit\"]")
      link_edit.click
    end

    scenario 'should edit a task' do
      fill_in 'Name', with: 'tarefa green'
      click_button 'Update'
      expect(page).to have_content('tarefa green')
    end

    context 'failure' do
      scenario 'normal' do
        fill_in 'Name', with: ''
        click_button 'Update'
        expect(page).to have_content("can't be blank")
      end

      scenario 'users that do not belong to the project' do
        login_as @goku
        visit edit_task_path(@task)

        expect(page).to have_content('goku@dbz.com')
        expect(current_path).to_not eq(edit_task_path(@task))
        expect(page).to have_content('You are not authorized to access this page.')
      end
    end
  end

  context 'delete' do
    before{ Task.create(name: 'tarefa xx', project_id: @project.id) }

    scenario 'successfully' do
      visit project_path @project
      expect(page).to have_content('tarefa xx')
      click_link 'Delete'
      expect(page).not_to have_content('tarefa xx')
    end

    scenario 'failure' do
      login_as @goku
      visit project_path @project
      expect(page).to_not have_content('tarefa xx')
    end
  end

  context 'listener' do
    scenario 'only owner should edit or destroy a tasks' do
      user = create(:user_confirmed)
      login_as user
      membership = create(:membership, project: @project, user: user,
       role: 'common_user')
      task2 = create(:task, project: @project, name: 'Task2')
      visit project_path(@project)
      click_link 'Sign'

      membership = create(:membership, project: @project, user: @user,
       role: 'admin')
      login_as @user
      task = create(:task, project: @project)
      visit project_path(@project)
      page.should have_css("a[href='/tasks/#{task.id}/edit']")
      page.should have_css("a[href='/tasks/#{task2.id}/edit']")
    end
  end
end