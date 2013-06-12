require 'spec_helper'

feature 'Task' do
  background do
    @user = create(:user_confirmed)
    login_as @user
    @project = create(:project)
  end

  context 'create' do
    background { visit project_path(@project) }

    scenario 'successfully create task and worktime' do
      time = Time.local(2008, 9, 1, 10, 5, 0)
      Timecop.freeze(time)
      fill_in 'Name', with: 'tarefa x'
      click_button 'Start'
      expect(page).to have_content('tarefa x')
      expect(page).to have_content('2008-09-01 13:05:00 UTC')
      Timecop.return
    end

    scenario 'failure' do
      fill_in 'Name', with: ''
      click_button 'Start'
      expect(page).to have_content("Task can't be created")
    end
  end

  context 'show' do
    scenario 'should show a task in the view of the project' do
      Task.create(name: 'tarefa xx', project_id: @project.id)
      visit project_path @project
      expect(page).to have_content('tarefa xx')
    end
  end

  context 'edit' do
    scenario 'should edit a task' do
      Task.create(name: 'tarefa xx', project_id: @project.id)
      visit project_path @project
      expect(page).to have_content('tarefa xx')
      click_link 'Edit'
      fill_in 'Name', with: 'tarefa green'
      click_button 'Update'
      expect(page).to have_content('tarefa green')
    end
  end

  context 'delete' do
    scenario 'should allow delete a task' do
      Task.create(name: 'tarefa xx', project_id: @project.id)
      visit project_path @project
      expect(page).to have_content('tarefa xx')
      click_link 'Delete'
      expect(page).not_to have_content('tarefa xx')
    end
  end
end