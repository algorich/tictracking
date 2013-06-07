require 'spec_helper'

feature 'Task' do
  background do
    @user = User.create(email: 'rodrigomageste@gmail.com',
     password: '123456')
    @user.confirm!
    login_as @user
    @project = Project.create(name: 'Project X')
  end

  context 'create' do
    background { visit project_path(@project) }

    scenario 'successfully' do
      fill_in 'Name', with: 'tarefa x'
      click_button 'Start'
      expect(page).to have_content 'tarefa x'
    end

    scenario 'failure' do
      fill_in 'Name', with: ''
      click_button 'Start'
      expect(page).to have_content "Não pode ser criado"
    end
  end


  context 'show' do
    scenario 'deve mostrar tarefa na view show do projeto' do
      Task.create(name: 'tarefa xx', project_id: @project.id, user_id: @user.id)
      visit project_path @project
      expect(page).to have_content 'tarefa xx'
    end
  end
end